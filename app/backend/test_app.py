import sys
from unittest.mock import patch, MagicMock

# Define Mock Exceptions and Classes before importing app
class MockUniqueViolation(Exception):
    pass

# Mock psycopg2
mock_psycopg2 = MagicMock()
mock_psycopg2.errors = MagicMock()
mock_psycopg2.errors.UniqueViolation = MockUniqueViolation
sys.modules['psycopg2'] = mock_psycopg2

# Mock psycopg2.extras
mock_psycopg2_extras = MagicMock()
sys.modules['psycopg2.extras'] = mock_psycopg2_extras

# Mock boto3 and botocore
sys.modules['boto3'] = MagicMock()
sys.modules['botocore'] = MagicMock()
sys.modules['botocore.exceptions'] = MagicMock()
sys.modules['botocore.config'] = MagicMock()

import unittest
import json
import os

# Set dummy env vars to satisfy app initialization
os.environ["DB_HOST"] = "localhost"
os.environ["DB_PORT"] = "5432"
os.environ["DB_USER"] = "dbadmin"
os.environ["DB_PASSWORD"] = "postgres"
os.environ["DB_NAME"] = "rhorizon_dev"
os.environ["S3_BUCKET_NAME"] = "rhorizon-local-assets"
os.environ["AWS_REGION"] = "eu-west-1"
os.environ["AWS_ACCESS_KEY_ID"] = "mock_key"
os.environ["AWS_SECRET_ACCESS_KEY"] = "mock_secret"

# Import app (which will now use the mocked modules)
from app import app

class TestApp(unittest.TestCase):
    def setUp(self):
        self.app = app.test_client()
        self.app.testing = True

    def test_liveness(self):
        response = self.app.get('/api/liveness')
        self.assertEqual(response.status_code, 200)
        data = json.loads(response.data.decode('utf-8'))
        self.assertEqual(data['status'], 'UP')

    @patch('app.get_db_connection')
    @patch('app.check_s3_health')
    def test_health_up(self, mock_s3_health, mock_db_conn):
        # Mock database connection check
        mock_conn = MagicMock()
        mock_cur = MagicMock()
        mock_conn.cursor.return_value = mock_cur
        mock_db_conn.return_value = mock_conn

        # Mock S3 check
        mock_s3_health.return_value = ("UP", None)

        response = self.app.get('/api/health')
        self.assertEqual(response.status_code, 200)
        data = json.loads(response.data.decode('utf-8'))
        self.assertEqual(data['status'], 'UP')
        self.assertEqual(data['database']['status'], 'UP')
        self.assertEqual(data['s3']['status'], 'UP')

    @patch('app.get_db_connection')
    @patch('app.check_s3_health')
    def test_health_degraded(self, mock_s3_health, mock_db_conn):
        # Mock database check to fail
        mock_db_conn.side_effect = Exception("Database Connection Refused")

        # Mock S3 check to fail
        mock_s3_health.return_value = ("DOWN", "S3 Connection Refused")

        response = self.app.get('/api/health')
        self.assertEqual(response.status_code, 500)
        data = json.loads(response.data.decode('utf-8'))
        self.assertEqual(data['status'], 'DEGRADED')
        self.assertEqual(data['database']['status'], 'DOWN')
        self.assertEqual(data['s3']['status'], 'DOWN')

    @patch('app.get_db_connection')
    def test_get_employees(self, mock_db_conn):
        # Mock connection and cursor
        mock_conn = MagicMock()
        mock_cur = MagicMock()
        mock_conn.cursor.return_value = mock_cur
        mock_db_conn.return_value = mock_conn

        # Mock query results
        import datetime
        mock_cur.fetchall.return_value = [
            {
                "id": 1,
                "name": "Alice Martin",
                "email": "alice.martin@rhorizon.xyz",
                "role": "Directrice RH",
                "created_at": datetime.datetime(2026, 5, 23, 12, 0, 0)
            }
        ]

        response = self.app.get('/api/employees')
        self.assertEqual(response.status_code, 200)
        data = json.loads(response.data.decode('utf-8'))
        self.assertEqual(len(data), 1)
        self.assertEqual(data[0]['name'], 'Alice Martin')
        self.assertEqual(data[0]['created_at'], '2026-05-23T12:00:00')

    @patch('app.get_db_connection')
    def test_add_employee(self, mock_db_conn):
        # Mock connection and cursor
        mock_conn = MagicMock()
        mock_cur = MagicMock()
        mock_conn.cursor.return_value = mock_cur
        mock_db_conn.return_value = mock_conn

        # Mock query results for newly added employee
        import datetime
        mock_cur.fetchone.return_value = {
            "id": 2,
            "name": "Thomas Bernard",
            "email": "thomas.bernard@rhorizon.xyz",
            "role": "Développeur DevOps",
            "created_at": datetime.datetime(2026, 5, 23, 12, 0, 0)
        }

        payload = {
            "name": "Thomas Bernard",
            "email": "thomas.bernard@rhorizon.xyz",
            "role": "Développeur DevOps"
        }

        response = self.app.post('/api/employees', data=json.dumps(payload), content_type='application/json')
        self.assertEqual(response.status_code, 201)
        data = json.loads(response.data.decode('utf-8'))
        self.assertEqual(data['id'], 2)
        self.assertEqual(data['email'], 'thomas.bernard@rhorizon.xyz')

    @patch('app.get_db_connection')
    def test_add_employee_missing_fields(self, mock_db_conn):
        payload = {
            "name": "Thomas Bernard"
        }
        response = self.app.post('/api/employees', data=json.dumps(payload), content_type='application/json')
        self.assertEqual(response.status_code, 400)

    @patch('app.get_db_connection')
    def test_update_employee(self, mock_db_conn):
        # Mock connection and cursor
        mock_conn = MagicMock()
        mock_cur = MagicMock()
        mock_conn.cursor.return_value = mock_cur
        mock_db_conn.return_value = mock_conn

        import datetime
        mock_cur.fetchone.return_value = {
            "id": 1,
            "name": "Alice Martin Updated",
            "email": "alice.martin@rhorizon.xyz",
            "role": "Directrice Générale",
            "created_at": datetime.datetime(2026, 5, 23, 12, 0, 0)
        }

        payload = {
            "name": "Alice Martin Updated",
            "email": "alice.martin@rhorizon.xyz",
            "role": "Directrice Générale"
        }

        response = self.app.put('/api/employees/1', data=json.dumps(payload), content_type='application/json')
        self.assertEqual(response.status_code, 200)
        data = json.loads(response.data.decode('utf-8'))
        self.assertEqual(data['role'], 'Directrice Générale')

    @patch('app.get_db_connection')
    def test_delete_employee(self, mock_db_conn):
        # Mock connection and cursor
        mock_conn = MagicMock()
        mock_cur = MagicMock()
        mock_conn.cursor.return_value = mock_cur
        mock_db_conn.return_value = mock_conn

        mock_cur.fetchone.return_value = {
            "id": 1,
            "email": "alice.martin@rhorizon.xyz"
        }

        response = self.app.delete('/api/employees/1')
        self.assertEqual(response.status_code, 200)
        data = json.loads(response.data.decode('utf-8'))
        self.assertEqual(data['message'], 'Employee deleted successfully')

if __name__ == '__main__':
    unittest.main()
