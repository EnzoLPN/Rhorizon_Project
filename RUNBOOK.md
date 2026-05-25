# Runbook & Guide de Démarrage

Ce document détaille les prérequis et les étapes nécessaires pour initialiser, déployer et exécuter le projet (infrastructure multi-comptes AWS et déploiement Kubernetes).

---

## 🛠️ 1. Prérequis Locaux (Poste de travail)

Avant de lancer le projet, assurez-vous d'avoir installé les outils suivants sur votre machine :

### Outils d'infrastructure :
*   **AWS CLI** (version >= 2.0) : Pour communiquer avec vos comptes AWS.
*   **AWS Session Manager Plugin** : **Obligatoire** pour pouvoir ouvrir des sessions sur le Bastion privé.
*   **Terraform** (version >= 1.9.0) : Pour déployer la Landing Zone.
*   **kubectl** (version >= 1.30) : Pour piloter les clusters EKS.
*   **Helm** (version >= 3.0) : Requis par Terraform pour l'installation automatique de l'observabilité.

---

## 🔑 2. Authentification AWS (SSO)

Le projet est configuré en mode multi-comptes avec AWS SSO. Configurez 4 profils CLI :
*   `aws-master`, `aws-shared`, `aws-nonprod`, `aws-prod`.

```bash
aws sso login --profile <nom_du_profil>
```

---

## 🏗️ 3. Déploiement de l'Infrastructure (Souveraineté Numérique)

> [!IMPORTANT]
> Par mesure de sécurité (prévention supply-chain attack), les pipelines d'infrastructure automatisés ont été supprimés. Le déploiement se fait manuellement depuis votre poste (ou bastion) après validation locale.
> **L'installation du Monitoring (Prometheus, Grafana, Fluent Bit) est incluse dans le déploiement Terraform.**

### Étape 1 : Shared Services (Central)
```bash
cd live/shared-services
aws sso login --profile aws-shared
terraform init && terraform apply
```

### Étape 2 : Environnement Applicatif (Non-Prod ou Prod)
```bash
cd ../nonprod # ou ../prod
aws sso login --profile aws-nonprod # ou aws-prod
terraform init && terraform apply
```

---

## 🚀 4. Déploiement Applicatif (EKS)

L'administration du cluster se fait en **privé uniquement**. Vous devez être connecté au compte AWS via SSO.

### A. Connexion au Cluster (via Bastion SSM)
L'API EKS n'est pas exposée sur Internet. Configurez votre accès :
```bash
aws eks update-kubeconfig --region eu-west-1 --name nonprod-eks-cluster --profile aws-nonprod
```

### B. Configuration des Variables (Exemple pour Non-Prod)
Les variables suivantes sont nécessaires pour le script de déploiement applicatif :

```bash
# Variables Globales
export PROJECT_NAME="rhorizon"
export ENVIRONMENT="nonprod"
export AWS_REGION="eu-west-1"
export IMAGE_TAG="latest"

# Accès Registre (Compte Shared)
export ECR_REGISTRY="<COMPTE_SHARED_ID>.dkr.ecr.eu-west-1.amazonaws.com"
export ECR_REPOSITORY="rhorizon/app"

# Accès Base de Données
export DB_HOST="<RDS_ENDPOINT>"
export DB_NAME="rhorizon_dev"
export DB_USER="dbadmin"

# Configuration Sécurité, S3 & Ingress
export DOMAIN_NAME="nonprod.rhorizon.xyz"
export S3_BUCKET_NAME="<S3_ASSETS_BUCKET_NAME>"
export ACM_CERT_ARN="<ACM_ARN_FROM_TERRAFORM_OUTPUT>"
export WAF_ACL_ARN="<WAF_ARN_FROM_TERRAFORM_OUTPUT>"
export APP_ROLE_ARN="<APP_IRSA_ROLE_ARN_FROM_TERRAFORM_OUTPUT>"
```

### C. Lancement du Déploiement
```bash
cd app/k8s
chmod +x deploy.sh
./deploy.sh
```

---

## 🔒 5. Spécificité Sécurité : IAM RDS Authentication

L'application backend utilise l'**Authentification IAM** (recommandation ANSSI) au lieu d'un mot de passe statique.
*   **Sur AWS (EKS)** : L'app détecte `USE_IAM_AUTH=true` et génère un jeton temporaire via son rôle IAM IRSA.

**Action manuelle requise** : Après le premier déploiement de RDS, connectez-vous via le Bastion et créez l'utilisateur avec les droits IAM :
```sql
CREATE USER dbadmin WITH LOGIN;
GRANT rds_iam TO dbadmin;
```
