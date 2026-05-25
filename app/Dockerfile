# ==========================================
# DOCKERFILE UNIFIÉ (MONOLITHE) - PROJET ASD
# Une seule image pour toute l'application
# ==========================================

FROM python:3.12-slim-bookworm

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

WORKDIR /app

# Sécurité & Dépendances système
# Nginx pour le front, Supervisor pour gérer les deux processus
RUN apt-get update && apt-get upgrade -y && \
    apt-get install -y --no-install-recommends \
    libpq-dev gcc nginx supervisor && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Installation des dépendances Python
COPY backend/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copie du code backend
COPY backend/app.py .

# Copie des fichiers frontend statiques dans le dossier Nginx
COPY frontend/index.html frontend/style.css frontend/app.js /usr/share/nginx/html/

# Configuration Nginx (Frontend sur / et API Proxy sur /api)
RUN echo 'server { \
    listen 8080; \
    location / { \
        root /usr/share/nginx/html; \
        index index.html; \
        try_files $uri $uri/ /index.html; \
    } \
    location /api { \
        proxy_pass http://127.0.0.1:5000; \
        proxy_set_header Host $host; \
        proxy_set_header X-Real-IP $remote_addr; \
    } \
}' > /etc/nginx/sites-available/default

# Configuration Supervisor pour lancer Nginx + Gunicorn
RUN echo "[supervisord]\nnodaemon=true\nlogfile=/tmp/supervisord.log\npidfile=/tmp/supervisord.pid\n\n[program:gunicorn]\ncommand=gunicorn --bind 127.0.0.1:5000 --workers 2 app:app\nautostart=true\nautorestart=true\nstdout_logfile=/dev/stdout\nstdout_logfile_maxbytes=0\nstderr_logfile=/dev/stderr\nstderr_logfile_maxbytes=0\n\n[program:nginx]\ncommand=nginx -g \"daemon off;\"\nautostart=true\nautorestart=true\nstdout_logfile=/dev/stdout\nstdout_logfile_maxbytes=0\nstderr_logfile=/dev/stderr\nstderr_logfile_maxbytes=0" > /etc/supervisord.conf

# Sécurisation des permissions pour utilisateur non-root
RUN groupadd -g 10001 appgroup && \
    useradd -u 10001 -g appgroup -s /bin/bash -m appuser && \
    chown -R appuser:appgroup /app /var/lib/nginx /var/log/nginx /etc/nginx /run

USER appuser
EXPOSE 8080

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisord.conf"]
