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
*   **Helm** (version >= 3.0) : Pour installer l'observabilité.

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

### Étape 1 : Shared Services (Central)
```bash
cd live/shared-services
aws sso login --profile aws-shared
terraform init && terraform apply
```

### Étape 2 : Environnement Applicatif (Non-Prod ou Prod)
```bash
cd ../nonprod # ou ../prod
aws sso login --profile aws-nonprod
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

### B. Configuration des Variables (Prêt à l'emploi pour Non-Prod)
Copiez-collez ce bloc en remplaçant `<ACCOUNT_ID_SHARED>` et `<RDS_ENDPOINT>` :

```bash
# Variables Globales
export PROJECT_NAME="rhorizon"
export ENVIRONMENT="nonprod"
export AWS_REGION="eu-west-1"
export IMAGE_TAG="latest"

# Accès Registre (Compte Shared)
export ECR_REGISTRY="<ACCOUNT_ID_SHARED>.dkr.ecr.eu-west-1.amazonaws.com"
export ECR_BACKEND_REPOSITORY="rhorizon/backend"
export ECR_FRONTEND_REPOSITORY="rhorizon/frontend"

# Accès Base de Données (Support IAM Auth activé)
export DB_HOST="<RDS_ENDPOINT>"
export DB_NAME="rhorizon"
export DB_USER="dbadmin"
export DB_PASSWORD_BASE64="Y2hhbmdlbWU=" # Non utilisé si USE_IAM_AUTH=true

# Configuration Sécurité & Ingress
export DOMAIN_NAME="nonprod.rhorizon.xyz"
export ACM_CERT_ARN="arn:aws:acm:..." # Output de terraform nonprod
export WAF_ACL_ARN="arn:aws:wafv2:..." # Output de terraform nonprod
export BACKEND_ROLE_ARN="arn:aws:iam::<ACCOUNT_ID_NONPROD>:role/rhorizon-nonprod-eks-secrets-role"
```

### C. Lancement du Déploiement
```bash
cd app/k8s
chmod +x deploy.sh
./deploy.sh all
```

---

## 🔒 5. Spécificité Sécurité : IAM RDS Authentication

L'application backend est configurée pour utiliser l'**Authentification IAM** au lieu d'un mot de passe statique.
*   **En local (Docker/LocalStack)** : L'app utilise `DB_PASSWORD`.
*   **Sur AWS (EKS)** : L'app détecte `USE_IAM_AUTH=true` et génère un jeton temporaire via son rôle IAM.

**Action manuelle requise** : Après le premier déploiement, assurez-vous de créer l'utilisateur `dbadmin` dans RDS et de lui accorder le rôle `rds_iam` (voir section "Hardening RDS" du rapport).
