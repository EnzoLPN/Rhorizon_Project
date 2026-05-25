# 📖 Runbook de Déploiement : Architecture ASD

Ce document détaille la logique de déploiement "Bootstrap" de la Landing Zone. Le projet repose sur une structure hiérarchique AWS où un compte **Master** pilote la création de l'ensemble de l'écosystème.

---

## 🛠️ 1. Concept de Base : Le Compte (Master)

Avant de commencer, vous **devez** posséder un compte AWS existant qui servira de **Compte Master (Management Account)**. 

### Pourquoi un compte Master ?
Dans une architecture multi-comptes industrielle, on n'utilise jamais le compte Root pour déployer des applications. Le compte Master a trois rôles uniques :
1.  **Provisionnement :** Il possède les droits programmatiques pour créer de nouveaux comptes AWS sans intervention manuelle via l'API `Organizations`.
2.  **Gouvernance :** Il applique les `Service Control Policies (SCP)` pour restreindre ce que les autres comptes ont le droit de faire.
3.  **Identité :** Il centralise l'authentification via AWS SSO (IAM Identity Center).

---

## 🏗️ 2. Déploiement Infrastructure (Le Workflow)

Le déploiement suit une séquence stricte. Chaque étape dépend de la réussite de la précédente.

### Étape 0 : Initialisation de l'Organisation (Compte Master)
C'est ici que l'infrastructure commence. Le code Terraform dans `live/global-org/` va demander au compte Master de créer physiquement les autres comptes.

1.  **Authentification :** Connectez votre CLI au compte Master.
2.  **Déploiement :**
    ```bash
    cd live/global-org/
    terraform init
    terraform apply
    ```
3.  **Résultat :** AWS va créer les comptes requis (`shared-services`, `nonprod`, `prod`). 
    *   *Note :* Un rôle nommé `OrganizationAccountAccessRole` est automatiquement créé dans chaque sous-compte pour permettre l'administration depuis le Master.

### Étape 1 : Activation du SSO (Action Manuelle Cruciale)
Une fois les comptes créés :
1.  Allez dans la console AWS du compte **Master**.
2.  Activez **IAM Identity Center**.
3.  **Configuration :** Créez vos utilisateurs et affectez-les aux comptes créés avec les permissions appropriées.
4.  **Profils CLI :** Lancez `aws configure sso` pour générer vos profils locaux.

### Étape 2 : Shared Services (Le Coeur de la CI/CD)
Maintenant que vous avez accès au compte Shared :
1.  **Déploiement :**
    ```bash
    cd live/shared-services/
    terraform init
    terraform apply
    ```
2.  **Rôle :** Cette étape crée le registre ECR et la passerelle OIDC pour GitHub Actions.

### Étape 3 : Environnements Applicatifs (Non-Prod / Prod)
Enfin, déployez l'infrastructure cible.
1.  **Déploiement :**
    ```bash
    cd live/nonprod/
    terraform init
    terraform apply
    ```

---

## 🔐 3. Configuration GitHub (Variables CI/CD)

Renseignez les variables dans GitHub (`Settings > Secrets and variables > Actions`) :

| Variable | Description |
| :--- | :--- |
| `PROJECT_NAME` | Nom de votre projet |
| `AWS_REGION` | Région de déploiement |
| `ECR_REGISTRY` | URL du registre ECR |
| `EKS_CLUSTER_NAME` | Nom du cluster EKS |
| `DOMAIN_NAME` | Nom de domaine (ex: nonprod.votre-domaine.com) |
| `ACM_CERT_ARN` | ARN du certificat SSL |
| `WAF_ACL_ARN` | ARN de la Web ACL |
| `DB_HOST` | Endpoint de la base RDS |
| `DB_NAME` | Nom de la base de données |
| `DB_USER` | Utilisateur master DB |
| `S3_BUCKET_NAME` | Bucket d'assets |
| `AWS_ROLE_ARN` | Rôle OIDC (Compte Shared) |
| `AWS_NONPROD_ROLE_ARN` | Rôle de déploiement (Compte Non-Prod) |
| `APP_ROLE_ARN` | Rôle IRSA pour l'application |

---

## 🚀 4. Déploiement Applicatif

Le déploiement est piloté par GitHub Actions.

### Déploiement en Production
Le job de production est par défaut désactivé pour plus de sécurité. Pour l'activer :
1.  **Décommentez** le job `deployment-prod` dans `.github/workflows/main.yml`.
2.  **Approbation manuelle :** Configurez l'environnement `PROD` sur GitHub avec l'option **"Required reviewers"**.

---
## 🔄 5. Maintenance
Utilisez `terraform apply` pour les changements d'infrastructure et poussez sur GitHub pour les mises à jour applicatives.
