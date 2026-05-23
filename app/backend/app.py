import os
import logging
from flask import Flask, jsonify, request
from flask_cors import CORS
import psycopg2
from psycopg2.extras import RealDictCursor
import boto3
from botocore.exceptions import ClientError
from botocore.config import Config

# Configure logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s %(levelname)s: %(message)s')
logger = logging.getLogger(__name__)

app = Flask(__name__)
# Enable CORS for all routes (important for development and split frontend/backend architecture)
CORS(app, resources={r"/api/*": {"origins": "*"}})

# DB Configuration from environment variables
DB_HOST = os.environ.get("DB_HOST", "localhost")
DB_PORT = os.environ.get("DB_PORT", "5432")
DB_USER = os.environ.get("DB_USER", "dbadmin")
DB_PASSWORD = os.environ.get("DB_PASSWORD", "postgres")
DB_NAME = os.environ.get("DB_NAME", "rhorizon_dev")

# S3 Configuration from environment variables
S3_BUCKET_NAME = os.environ.get("S3_BUCKET_NAME", "rhorizon-local-assets")
AWS_REGION = os.environ.get("AWS_REGION", "eu-west-1")
S3_ENDPOINT_URL = os.environ.get("S3_ENDPOINT_URL")

# Initialize S3 client with a short timeout to prevent startup deadlock when offline
s3_config = Config(
    connect_timeout=2.0,
    read_timeout=2.0,
    retries={'max_attempts': 2}
)

s3_kwargs = {
    "region_name": AWS_REGION,
    "config": s3_config
}
if S3_ENDPOINT_URL:
    logger.info(f"Configuring S3 client with endpoint: {S3_ENDPOINT_URL}")
    s3_kwargs["endpoint_url"] = S3_ENDPOINT_URL
    s3_kwargs["aws_access_key_id"] = os.environ.get("AWS_ACCESS_KEY_ID", "mock")
    s3_kwargs["aws_secret_access_key"] = os.environ.get("AWS_SECRET_ACCESS_KEY", "mock")

s3_client = boto3.client('s3', **s3_kwargs)

def init_s3_bucket():
    """Initializes the S3 bucket on LocalStack if running in development mode."""
    if S3_ENDPOINT_URL:
        try:
            logger.info(f"Checking S3 bucket '{S3_BUCKET_NAME}' at endpoint '{S3_ENDPOINT_URL}'...")
            s3_client.head_bucket(Bucket=S3_BUCKET_NAME)
            logger.info(f"S3 bucket '{S3_BUCKET_NAME}' already exists.")
        except ClientError as e:
            error_code = e.response.get('Error', {}).get('Code')
            if error_code in ['404', '403', 'NoSuchBucket']:
                try:
                    logger.info(f"S3 bucket '{S3_BUCKET_NAME}' not found. Creating bucket...")
                    if AWS_REGION == "us-east-1":
                        s3_client.create_bucket(Bucket=S3_BUCKET_NAME)
                    else:
                        s3_client.create_bucket(
                            Bucket=S3_BUCKET_NAME,
                            CreateBucketConfiguration={'LocationConstraint': AWS_REGION}
                        )
                    logger.info(f"S3 bucket '{S3_BUCKET_NAME}' created successfully.")
                except Exception as create_err:
                    logger.error(f"Failed to create S3 bucket '{S3_BUCKET_NAME}': {create_err}")
            else:
                logger.error(f"Error checking S3 bucket: {e}")
        except Exception as e:
            logger.error(f"General error while verifying S3 bucket: {e}")

def check_s3_health():
    """Verifies connectivity to S3 by performing a head_bucket operation."""
    s3_status = "UP"
    s3_error = None
    try:
        s3_client.head_bucket(Bucket=S3_BUCKET_NAME)
    except Exception as e:
        s3_status = "DOWN"
        s3_error = str(e)
        logger.error(f"S3 health check failed: {e}")
    return s3_status, s3_error

def get_db_connection():
    """Establishes a connection to the PostgreSQL database."""
    conn = psycopg2.connect(
        host=DB_HOST,
        port=DB_PORT,
        user=DB_USER,
        password=DB_PASSWORD,
        database=DB_NAME,
        connect_timeout=3
    )
    return conn

def init_db():
    """Initializes the database schema by creating the employees table if it doesn't exist."""
    conn = None
    try:
        conn = get_db_connection()
        cur = conn.cursor()
        
        # Create table if it doesn't exist
        cur.execute("""
            CREATE TABLE IF NOT EXISTS employees (
                id SERIAL PRIMARY KEY,
                name VARCHAR(100) NOT NULL,
                email VARCHAR(100) UNIQUE NOT NULL,
                role VARCHAR(100) NOT NULL,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            );
        """)
        
        # Check if table is empty, insert default employees for visual demo if empty
        cur.execute("SELECT COUNT(*) FROM employees;")
        count = cur.fetchone()[0]
        if count == 0:
            logger.info("Inserting demo employees...")
            demo_employees = [
                ("Alice Martin", "alice.martin@rhorizon.xyz", "Directrice RH"),
                ("Thomas Bernard", "thomas.bernard@rhorizon.xyz", "Développeur DevOps"),
                ("Sophie Petit", "sophie.petit@rhorizon.xyz", "Gestionnaire de paie")
            ]
            for name, email, role in demo_employees:
                cur.execute(
                    "INSERT INTO employees (name, email, role) VALUES (%s, %s, %s);",
                    (name, email, role)
                )
        
        conn.commit()
        cur.close()
        logger.info("Database initialized successfully.")
    except Exception as e:
        logger.error(f"Error during database initialization: {e}")
        if conn:
            conn.rollback()
    finally:
        if conn:
            conn.close()

# Initialize DB and S3 on startup
try:
    init_db()
except Exception as e:
    logger.error(f"Failed to initialize database on startup: {e}")

try:
    init_s3_bucket()
except Exception as e:
    logger.error(f"Failed to initialize S3 bucket on startup: {e}")

@app.route('/api/liveness', methods=['GET'])
def liveness():
    """Liveness check to verify the process is alive without querying deep dependencies."""
    return jsonify({"status": "UP"}), 200

@app.route('/api/health', methods=['GET'])
def health():
    """Health check endpoint to check API status, database and S3 connectivity."""
    db_status = "UP"
    db_error = None
    try:
        conn = get_db_connection()
        cur = conn.cursor()
        cur.execute("SELECT 1;")
        cur.close()
        conn.close()
    except Exception as e:
        db_status = "DOWN"
        db_error = str(e)
        logger.error(f"Database healthcheck failed: {e}")

    s3_status, s3_error = check_s3_health()
    overall_status = "UP" if (db_status == "UP" and s3_status == "UP") else "DEGRADED"

    return jsonify({
        "status": overall_status,
        "database": {
            "status": db_status,
            "host": DB_HOST,
            "database_name": DB_NAME,
            "error": db_error
        },
        "s3": {
            "status": s3_status,
            "bucket_name": S3_BUCKET_NAME,
            "region": AWS_REGION,
            "error": s3_error
        }
    }), 200 if overall_status == "UP" else 500

@app.route('/api/s3/test', methods=['GET', 'POST'])
def test_s3():
    """Performs a write, read, and delete test cycle on the S3 bucket to validate IAM/network connectivity."""
    import uuid
    import time
    
    test_key = f"test-connection-{uuid.uuid4().hex[:8]}.txt"
    test_content = f"RHZORION S3 Validation. Timestamp: {time.time()}"
    
    steps = []
    success = True
    error_msg = None
    
    # Step 1: Write (PutObject)
    try:
        start_time = time.time()
        s3_client.put_object(
            Bucket=S3_BUCKET_NAME,
            Key=test_key,
            Body=test_content.encode('utf-8'),
            ContentType='text/plain'
        )
        duration = round((time.time() - start_time) * 1000, 2)
        steps.append({
            "step": "write",
            "status": "success",
            "details": f"Fichier '{test_key}' écrit avec succès en {duration}ms"
        })
    except Exception as e:
        success = False
        error_msg = f"Échec de l'écriture: {str(e)}"
        steps.append({
            "step": "write",
            "status": "failed",
            "details": error_msg
        })
        
    # Step 2: Read (GetObject)
    if success:
        try:
            start_time = time.time()
            response = s3_client.get_object(
                Bucket=S3_BUCKET_NAME,
                Key=test_key
            )
            content = response['Body'].read().decode('utf-8')
            duration = round((time.time() - start_time) * 1000, 2)
            
            if content == test_content:
                steps.append({
                    "step": "read",
                    "status": "success",
                    "details": f"Fichier lu avec succès en {duration}ms (Contenu valide)"
                })
            else:
                success = False
                error_msg = f"Contenu du fichier invalide: attendu '{test_content}', obtenu '{content}'"
                steps.append({
                    "step": "read",
                    "status": "failed",
                    "details": error_msg
                })
        except Exception as e:
            success = False
            error_msg = f"Échec de la lecture: {str(e)}"
            steps.append({
                "step": "read",
                "status": "failed",
                "details": error_msg
            })
            
    # Step 3: Delete (DeleteObject)
    if len(steps) >= 1 and steps[0]["status"] == "success":
        try:
            start_time = time.time()
            s3_client.delete_object(
                Bucket=S3_BUCKET_NAME,
                Key=test_key
            )
            duration = round((time.time() - start_time) * 1000, 2)
            steps.append({
                "step": "delete",
                "status": "success",
                "details": f"Fichier supprimé avec succès en {duration}ms"
            })
        except Exception as e:
            success = False
            error_msg = f"Échec de la suppression: {str(e)}"
            steps.append({
                "step": "delete",
                "status": "failed",
                "details": error_msg
            })
            
    return jsonify({
        "success": success,
        "bucket": S3_BUCKET_NAME,
        "region": AWS_REGION,
        "steps": steps,
        "error": error_msg
    }), 200 if success else 500


@app.route('/api/employees', methods=['GET'])
def get_employees():
    """Retrieve all employees from the database."""
    conn = None
    try:
        conn = get_db_connection()
        # Use RealDictCursor to return results as dictionaries
        cur = conn.cursor(cursor_factory=RealDictCursor)
        cur.execute("SELECT id, name, email, role, created_at FROM employees ORDER BY id DESC;")
        employees = cur.fetchall()
        cur.close()
        
        # Format timestamps to string
        for emp in employees:
            if emp['created_at']:
                emp['created_at'] = emp['created_at'].isoformat()
                
        return jsonify(employees), 200
    except Exception as e:
        logger.error(f"Error fetching employees: {e}")
        return jsonify({"error": "Failed to fetch employees", "details": str(e)}), 500
    finally:
        if conn:
            conn.close()

@app.route('/api/employees', methods=['POST'])
def add_employee():
    """Create a new employee in the database."""
    data = request.get_json()
    if not data or not data.get('name') or not data.get('email') or not data.get('role'):
        return jsonify({"error": "Missing required fields (name, email, role)"}), 400
        
    conn = None
    try:
        conn = get_db_connection()
        cur = conn.cursor(cursor_factory=RealDictCursor)
        
        cur.execute(
            "INSERT INTO employees (name, email, role) VALUES (%s, %s, %s) RETURNING id, name, email, role, created_at;",
            (data['name'], data['email'], data['role'])
        )
        new_emp = cur.fetchone()
        conn.commit()
        cur.close()
        
        if new_emp['created_at']:
            new_emp['created_at'] = new_emp['created_at'].isoformat()
            
        logger.info(f"Successfully added employee: {new_emp['email']}")
        return jsonify(new_emp), 201
    except psycopg2.errors.UniqueViolation as e:
        if conn:
            conn.rollback()
        logger.warning(f"Duplicate email attempt: {data['email']}")
        return jsonify({"error": "An employee with this email already exists"}), 409
    finally:
        if conn:
            conn.close()

@app.route('/api/employees/<int:emp_id>', methods=['PUT'])
def update_employee(emp_id):
    """Update an existing employee in the database."""
    data = request.get_json()
    if not data or not data.get('name') or not data.get('email') or not data.get('role'):
        return jsonify({"error": "Missing required fields (name, email, role)"}), 400
        
    conn = None
    try:
        conn = get_db_connection()
        cur = conn.cursor(cursor_factory=RealDictCursor)
        
        cur.execute(
            "UPDATE employees SET name = %s, email = %s, role = %s WHERE id = %s RETURNING id, name, email, role, created_at;",
            (data['name'], data['email'], data['role'], emp_id)
        )
        updated_emp = cur.fetchone()
        conn.commit()
        cur.close()
        
        if not updated_emp:
            return jsonify({"error": "Employee not found"}), 404
            
        if updated_emp['created_at']:
            updated_emp['created_at'] = updated_emp['created_at'].isoformat()
            
        logger.info(f"Successfully updated employee: {updated_emp['email']}")
        return jsonify(updated_emp), 200
    except psycopg2.errors.UniqueViolation as e:
        if conn:
            conn.rollback()
        logger.warning(f"Duplicate email attempt during update: {data['email']}")
        return jsonify({"error": "An employee with this email already exists"}), 409
    except Exception as e:
        if conn:
            conn.rollback()
        logger.error(f"Error updating employee: {e}")
        return jsonify({"error": "Failed to update employee", "details": str(e)}), 500
    finally:
        if conn:
            conn.close()

@app.route('/api/employees/<int:emp_id>', methods=['DELETE'])
def delete_employee(emp_id):
    """Delete an employee from the database."""
    conn = None
    try:
        conn = get_db_connection()
        cur = conn.cursor(cursor_factory=RealDictCursor)
        
        cur.execute("DELETE FROM employees WHERE id = %s RETURNING id, email;", (emp_id,))
        deleted_emp = cur.fetchone()
        conn.commit()
        cur.close()
        
        if not deleted_emp:
            return jsonify({"error": "Employee not found"}), 404
            
        logger.info(f"Successfully deleted employee: {deleted_emp['email']}")
        return jsonify({"message": "Employee deleted successfully", "id": emp_id}), 200
    except Exception as e:
        if conn:
            conn.rollback()
        logger.error(f"Error deleting employee: {e}")
        return jsonify({"error": "Failed to delete employee", "details": str(e)}), 500
    finally:
        if conn:
            conn.close()

if __name__ == '__main__':
    # Running flask in debug mode for development (Gunicorn will run it in production/K8s)
    app.run(host='0.0.0.0', port=5000)
