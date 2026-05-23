// Determine API base URL dynamically:
// (Triggered rebuild with unique tag timestamps)
// If running on a unified Ingress (e.g. EKS ALB), we can use relative path '/api'.
const API_BASE = '/api';


// DOM Elements
const globalStatusBadge = document.getElementById('global-status-badge');
const dbHostEl = document.getElementById('db-host');
const dbNameEl = document.getElementById('db-name');
const dbConnStatusEl = document.getElementById('db-conn-status');
const dbErrorRow = document.getElementById('db-error-row');
const dbErrorMsgEl = document.getElementById('db-error-msg');

const s3BucketEl = document.getElementById('s3-bucket');
const s3RegionEl = document.getElementById('s3-region');
const s3ConnBadge = document.getElementById('s3-conn-badge');
const s3ErrorRow = document.getElementById('s3-error-row');
const s3ErrorMsgEl = document.getElementById('s3-error-msg');
const testS3Btn = document.getElementById('test-s3-btn');
const s3Spinner = document.getElementById('s3-spinner');
const s3LogsContainer = document.getElementById('s3-logs-container');
const s3LogsEl = document.getElementById('s3-logs');

const addEmployeeForm = document.getElementById('add-employee-form');
const submitBtn = document.getElementById('submit-btn');
const formMessage = document.getElementById('form-message');
const refreshListBtn = document.getElementById('refresh-list-btn');
const employeesListBody = document.getElementById('employees-list-body');

// Helper to update badges
function updateStatusBadge(element, statusText, statusClass) {
    element.className = `badge ${statusClass}`;
    element.querySelector('.badge-text').textContent = statusText;
}

// Fetch Health, DB, and S3 status
async function checkHealth() {
    try {
        const response = await fetch(`${API_BASE}/health`);
        const data = await response.json();
        
        // 1. Update Global Badge
        if (data.status === 'UP') {
            updateStatusBadge(globalStatusBadge, 'Opérationnel', 'badge-online');
        } else if (data.status === 'DEGRADED') {
            updateStatusBadge(globalStatusBadge, 'Dégradé', 'badge-checking');
        } else {
            updateStatusBadge(globalStatusBadge, 'Incident', 'badge-offline');
        }
        
        // 2. Update DB status UI
        if (data.database) {
            dbHostEl.textContent = data.database.host || '--';
            dbNameEl.textContent = data.database.database_name || '--';
            
            if (data.database.status === 'UP') {
                dbConnStatusEl.textContent = 'Connecté (Active)';
                dbConnStatusEl.className = 'status-value status-active';
                dbErrorRow.style.display = 'none';
            } else {
                dbConnStatusEl.textContent = 'Erreur Connexion';
                dbConnStatusEl.className = 'status-value status-inactive';
                dbErrorRow.style.display = 'flex';
                dbErrorMsgEl.textContent = data.database.error || 'Erreur base de données inconnue.';
            }
        }
        
        // 3. Update S3 status UI
        if (data.s3) {
            s3BucketEl.textContent = data.s3.bucket_name || '--';
            s3RegionEl.textContent = data.s3.region || '--';
            
            if (data.s3.status === 'UP') {
                updateStatusBadge(s3ConnBadge, 'Opérationnel', 'badge-online');
                s3ErrorRow.style.display = 'none';
            } else {
                updateStatusBadge(s3ConnBadge, 'Erreur Connexion', 'badge-offline');
                s3ErrorRow.style.display = 'flex';
                s3ErrorMsgEl.textContent = data.s3.error || 'Erreur stockage S3 inconnue.';
            }
        }
    } catch (error) {
        // API is unreachable
        logger_error(error);
        updateStatusBadge(globalStatusBadge, 'API Inaccessible', 'badge-offline');
        
        dbConnStatusEl.textContent = 'Indisponible';
        dbConnStatusEl.className = 'status-value status-inactive';
        dbErrorRow.style.display = 'flex';
        dbErrorMsgEl.textContent = "Impossible de joindre le backend de l'application.";
        
        updateStatusBadge(s3ConnBadge, 'Indisponible', 'badge-offline');
        s3ErrorRow.style.display = 'flex';
        s3ErrorMsgEl.textContent = "Impossible de joindre le backend de l'application pour vérifier S3.";
    }
}

// Fetch and render employees list
async function fetchEmployees() {
    try {
        const response = await fetch(`${API_BASE}/employees`);
        if (!response.ok) throw new Error("Erreur de récupération des données.");
        
        const employees = await response.json();
        renderEmployees(employees);
    } catch (error) {
        logger_error(error);
        employeesListBody.innerHTML = `
            <tr class="placeholder-row">
                <td colspan="6" class="error-text">Impossible de charger les collaborateurs.</td>
            </tr>
        `;
    }
}

function renderEmployees(employees) {
    if (employees.length === 0) {
        employeesListBody.innerHTML = `
            <tr class="placeholder-row">
                <td colspan="6">Aucun collaborateur enregistré pour le moment.</td>
            </tr>
        `;
        return;
    }
    
    employeesListBody.innerHTML = employees.map(emp => {
        const dateFormatted = emp.created_at 
            ? new Date(emp.created_at).toLocaleDateString('fr-FR', {
                day: 'numeric',
                month: 'short',
                year: 'numeric',
                hour: '2-digit',
                minute: '2-digit'
              })
            : '--';
            
        return `
            <tr>
                <td><strong>#${emp.id}</strong></td>
                <td>${escapeHTML(emp.name)}</td>
                <td>${escapeHTML(emp.email)}</td>
                <td><span class="role-tag">${escapeHTML(emp.role)}</span></td>
                <td>${dateFormatted}</td>
                <td>
                    <div class="action-buttons">
                        <button class="btn-action edit-btn" 
                                data-id="${emp.id}" 
                                data-name="${escapeHTML(emp.name)}" 
                                data-email="${escapeHTML(emp.email)}" 
                                data-role="${escapeHTML(emp.role)}">
                            Modifier
                        </button>
                        <button class="btn-action delete-btn" data-id="${emp.id}">
                            Supprimer
                        </button>
                    </div>
                </td>
            </tr>
        `;
    }).join('');
}

// Modal DOM Elements
const editModal = document.getElementById('edit-modal');
const closeModelBtn = document.getElementById('close-modal-btn');
const cancelEditBtn = document.getElementById('cancel-edit-btn');
const editEmployeeForm = document.getElementById('edit-employee-form');
const editSubmitBtn = document.getElementById('edit-submit-btn');
const editFormMessage = document.getElementById('edit-form-message');

function closeEditModal() {
    editModal.classList.remove('active');
    editEmployeeForm.reset();
}

closeModelBtn.addEventListener('click', closeEditModal);
cancelEditBtn.addEventListener('click', closeEditModal);

// Close modal when clicking outside the content
window.addEventListener('click', (e) => {
    if (e.target === editModal) {
        closeEditModal();
    }
});

// Event delegation for table action buttons
employeesListBody.addEventListener('click', (e) => {
    const target = e.target;
    
    if (target.classList.contains('edit-btn')) {
        const id = target.getAttribute('data-id');
        const name = target.getAttribute('data-name');
        const email = target.getAttribute('data-email');
        const role = target.getAttribute('data-role');
        
        document.getElementById('edit-emp-id').value = id;
        document.getElementById('edit-emp-name').value = name;
        document.getElementById('edit-emp-email').value = email;
        document.getElementById('edit-emp-role').value = role;
        
        editFormMessage.style.display = 'none';
        editModal.classList.add('active');
    }
    
    if (target.classList.contains('delete-btn')) {
        const id = target.getAttribute('data-id');
        deleteEmployee(id);
    }
});

// Delete Employee Handler
async function deleteEmployee(id) {
    if (!confirm("Êtes-vous sûr de vouloir supprimer ce collaborateur ?")) return;
    
    try {
        const response = await fetch(`${API_BASE}/employees/${id}`, {
            method: 'DELETE'
        });
        
        if (response.ok) {
            fetchEmployees();
            checkHealth();
        } else {
            const result = await response.json();
            alert(result.error || "Une erreur est survenue lors de la suppression.");
        }
    } catch (error) {
        logger_error(error);
        alert("Erreur réseau: impossible de supprimer le collaborateur.");
    }
}

// Edit Employee Form Submission
editEmployeeForm.addEventListener('submit', async (e) => {
    e.preventDefault();
    
    const id = document.getElementById('edit-emp-id').value;
    
    const submitBtnText = editSubmitBtn.querySelector('.btn-text');
    const spinner = editSubmitBtn.querySelector('.spinner');
    
    editSubmitBtn.disabled = true;
    submitBtnText.style.opacity = '0.5';
    spinner.style.display = 'inline-block';
    editFormMessage.style.display = 'none';
    
    const payload = {
        name: document.getElementById('edit-emp-name').value,
        email: document.getElementById('edit-emp-email').value,
        role: document.getElementById('edit-emp-role').value
    };
    
    try {
        const response = await fetch(`${API_BASE}/employees/${id}`, {
            method: 'PUT',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify(payload)
        });
        
        const result = await response.json();
        
        if (response.ok) {
            closeEditModal();
            fetchEmployees();
            checkHealth();
        } else {
            showEditFormMessage(result.error || "Une erreur est survenue.", 'message-error');
        }
    } catch (error) {
        logger_error(error);
        showEditFormMessage("Erreur réseau: impossible de mettre à jour le collaborateur.", 'message-error');
    } finally {
        editSubmitBtn.disabled = false;
        submitBtnText.style.opacity = '1';
        spinner.style.display = 'none';
    }
});

function showEditFormMessage(text, className) {
    editFormMessage.textContent = text;
    editFormMessage.className = `message-banner ${className}`;
    editFormMessage.style.display = 'block';
}

// Handle Add Employee submission
addEmployeeForm.addEventListener('submit', async (e) => {
    e.preventDefault();
    
    // UI state: loading
    const submitBtnText = submitBtn.querySelector('.btn-text');
    const spinner = submitBtn.querySelector('.spinner');
    
    submitBtn.disabled = true;
    submitBtnText.style.opacity = '0.5';
    spinner.style.display = 'inline-block';
    
    formMessage.style.display = 'none';
    
    const payload = {
        name: document.getElementById('emp-name').value,
        email: document.getElementById('emp-email').value,
        role: document.getElementById('emp-role').value
    };
    
    try {
        const response = await fetch(`${API_BASE}/employees`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify(payload)
        });
        
        const result = await response.json();
        
        if (response.status === 201) {
            showFormMessage('Collaborateur enregistré avec succès !', 'message-success');
            addEmployeeForm.reset();
            // Refresh list
            fetchEmployees();
            // Check health to update status
            checkHealth();
        } else {
            showFormMessage(result.error || "Une erreur est survenue.", 'message-error');
        }
    } catch (error) {
        logger_error(error);
        showFormMessage("Erreur réseau: impossible de soumettre les données.", 'message-error');
    } finally {
        submitBtn.disabled = false;
        submitBtnText.style.opacity = '1';
        spinner.style.display = 'none';
    }
});

function showFormMessage(text, className) {
    formMessage.textContent = text;
    formMessage.className = `message-banner ${className}`;
    formMessage.style.display = 'block';
}

// Refresh button listener
refreshListBtn.addEventListener('click', () => {
    checkHealth();
    fetchEmployees();
});

// Test S3 action button listener
testS3Btn.addEventListener('click', async () => {
    // UI state: loading
    testS3Btn.disabled = true;
    s3Spinner.style.display = 'inline-block';
    
    // Clear and display logs container
    s3LogsEl.innerHTML = '';
    s3LogsContainer.style.display = 'block';
    
    const addLog = (text, type = 'info') => {
        const timeStr = new Date().toLocaleTimeString('fr-FR', { hour12: false });
        const entry = document.createElement('div');
        entry.className = 'log-entry';
        entry.innerHTML = `
            <span class="log-time">[${timeStr}]</span>
            <span class="log-text log-${type}">${escapeHTML(text)}</span>
        `;
        s3LogsEl.appendChild(entry);
        s3LogsEl.scrollTop = s3LogsEl.scrollHeight;
    };
    
    addLog("Initialisation du cycle de test S3...", "info");
    
    try {
        const response = await fetch(`${API_BASE}/s3/test`, {
            method: 'POST'
        });
        const result = await response.json();
        
        if (response.ok && result.success) {
            updateStatusBadge(s3ConnBadge, 'Opérationnel', 'badge-online');
            s3ErrorRow.style.display = 'none';
            
            // Render step details
            if (result.steps) {
                result.steps.forEach(step => {
                    addLog(step.details, step.status === 'success' ? 'success' : 'failed');
                });
            }
            addLog("Test de stockage S3 complété avec succès !", "success");
        } else {
            updateStatusBadge(s3ConnBadge, 'Erreur Connexion', 'badge-offline');
            if (result.steps) {
                result.steps.forEach(step => {
                    addLog(step.details, step.status === 'success' ? 'success' : 'failed');
                });
            }
            addLog(`Échec du test de stockage S3: ${result.error || 'Erreur inconnue'}`, "failed");
            
            s3ErrorRow.style.display = 'flex';
            s3ErrorMsgEl.textContent = result.error || 'Erreur lors de l\'exécution du test.';
        }
    } catch (error) {
        logger_error(error);
        updateStatusBadge(s3ConnBadge, 'Erreur Réseau', 'badge-offline');
        addLog(`Erreur de communication avec le serveur: ${error.message}`, "failed");
        
        s3ErrorRow.style.display = 'flex';
        s3ErrorMsgEl.textContent = "Impossible d'exécuter le test S3 sur le backend.";
    } finally {
        testS3Btn.disabled = false;
        s3Spinner.style.display = 'none';
        // Refresh health status to update database and S3 badges globally
        checkHealth();
    }
});

// HTML escaping helper to prevent XSS
function escapeHTML(str) {
    return str.replace(/[&<>'"]/g, 
        tag => ({
            '&': '&amp;',
            '<': '&lt;',
            '>': '&gt;',
            "'": '&#39;',
            '"': '&quot;'
        }[tag] || tag)
    );
}

function logger_error(err) {
    console.error('[RHZORION Dashboard]', err);
}

// Initial load
checkHealth();
fetchEmployees();
// Poll health every 30 seconds
setInterval(checkHealth, 30000);
