# Utilisation d'une image Python 3.12 Slim sur Bookworm (Debian 12) pour plus de stabilité et sécurité
FROM python:3.12-slim-bookworm

WORKDIR /app

# Mise à jour du système et installation des dépendances minimales
# On force l'upgrade pour corriger les CVE présentes dans l'image de base (krb5, ncurses, etc.)
RUN apt-get update && apt-get upgrade -y && \
    apt-get install -y --no-install-recommends \
    libpq-dev \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Mise à jour de pip, setuptools et wheel vers les dernières versions sécurisées (Corrige CVE-2026-24049)
RUN pip install --no-cache-dir --upgrade pip setuptools wheel

COPY requirements.txt .
# Installation des dépendances Python
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

# Création d'un utilisateur non-root avec des permissions restreintes
RUN useradd -m -u 10001 appuser && \
    chown -R appuser:appuser /app && \
    chmod -R 755 /app

USER appuser

EXPOSE 5000

ENV FLASK_APP=app.py
ENV FLASK_ENV=production
ENV PYTHONUNBUFFERED=1
ENV PYTHONDONTWRITEBYTECODE=1

# Utilisation de Gunicorn avec des paramètres de sécurité
CMD ["gunicorn", "--bind", "0.0.0.0:5000", "--workers", "2", "--timeout", "30", "--keep-alive", "2", "app:app"]
