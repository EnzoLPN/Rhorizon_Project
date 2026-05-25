# ==========================================
# DOCKERFILE UNIFIÉ - PROJET ASD (RHORIZON)
# Utilise les "Targets" pour builder le Front ou le Back
# ==========================================

# --- ÉTAPE 1 : BACKEND (Target: backend) ---
FROM python:3.12-slim-bookworm AS backend

# Paramètres de sécurité Python
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1
ENV PIP_NO_CACHE_DIR=1

WORKDIR /app

# Installation des dépendances système et mise à jour de sécurité (ANSSI)
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y --no-install-recommends \
    libpq-dev gcc && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Création d'un utilisateur non-privilégié (ANSSI)
RUN groupadd -g 10001 appgroup && \
    useradd -u 10001 -g appgroup -s /bin/bash -m appuser

# Installation des dépendances Python
COPY backend/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copie du code source
COPY backend/app.py .

# Sécurisation des permissions
RUN chown -R appuser:appgroup /app
USER appuser

EXPOSE 5000

# Lancement avec Gunicorn (Production-ready)
CMD ["gunicorn", "--bind", "0.0.0.0:5000", "--workers", "2", "app:app"]


# --- ÉTAPE 2 : FRONTEND (Target: frontend) ---
FROM nginxinc/nginx-unprivileged:alpine AS frontend

WORKDIR /usr/share/nginx/html

# Copie des fichiers statiques
COPY frontend/index.html frontend/style.css frontend/app.js ./

# Copie de la configuration Nginx durcie
COPY frontend/nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 8080

CMD ["nginx", "-g", "daemon off;"]
