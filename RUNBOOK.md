# 📖 Runbook de Déploiement : Architecture ASD

Ce document détaille la logique de déploiement "Bootstrap" de la Landing Zone. Le projet repose sur une structure hiérarchique AWS où un compte **Master** pilote la création de l'ensemble de l'écosystème.

---

## 🛠️ 1. Concept de Base : Le Compte (Master)

Avant de commencer, vous **devez** posséder un compte AWS existant qui servira de **Compte Master (Management Account)**. 

### Pourquoi un compte Master ?
Dans une architecture multi-comptes industrielle, on n'utilise jamais le compte Root pour déployer des applications. Le compte Master a trois rôles uniques :
1.  **Provisionnement :** Il possède les droits programmatiques pour créer de nouveaux comptes AWS sans intervention manuelle via l'API `Organizations`.
2.  **Gouvernance :** Il applique les `Service Control Policies (SCP)` pour restreindre ce que les autres comptes ont le droit de faire (ex: interdire de quitter l'organisation).
3.  **Identité :** Il centralise l'authentification via AWS SSO (IAM Identity Center).

---

## 🏗️ 2. Déploiement Infrastructure (Le Workflow)

Le déploiement suit une séquence stricte. Chaque étape dépend de la réussite de la précédente.

### Étape 0 : Initialisation de l'Organisation (Compte Master)
C'est ici que "la magie" opère. Le code Terraform dans `live/global-org/` va demander au compte Master de créer physiquement les autres comptes.

1.  **Authentification :** Connectez votre CLI au compte Master (via clé d'accès ou session).
2.  **Déploiement :**
    ```bash
    cd live/global-org/
    terraform init
    terraform apply
    ```
3.  **Résultat :** AWS va créer trois nouveaux comptes (`shared-services`, `nonprod`, `prod`). 
    *   *Note :* Un rôle nommé `OrganizationAccountAccessRole` est automatiquement créé dans chaque sous-compte. Il permet au compte Master d'administrer ces comptes sans mot de passe.

### Étape 1 : Activation du SSO (Action Manuelle Cruciale)
Une fois les comptes créés, ils sont "vides" d'utilisateurs. Pour y accéder proprement :
1.  Allez dans la console AWS du compte **Master**.
2.  Activez **IAM Identity Center**.
3.  **Configuration :**
    *   Créez un utilisateur (ex: votre nom).
    *   Créez des groupes (ex: `Admins`).
    *   **Assignation :** Liez votre utilisateur/groupe aux comptes créés (`shared`, `nonprod`, `prod`) avec la politique `AdministratorAccess`.
4.  **Profils CLI :** Lancez `aws configure sso` sur votre machine pour générer les profils `aws-shared`, `aws-nonprod`, etc.

### Étape 2 : Shared Services (Le Coeur de la CI/CD)
Maintenant que vous avez accès au compte Shared via SSO :
1.  **Déploiement :**
    ```bash
    cd live/shared-services/
    # Utilisez le profil SSO créé précédemment
    export AWS_PROFILE=aws-shared 
    terraform init
    terraform apply
    ```
2.  **Rôle :** Cette étape crée le registre ECR et la passerelle OIDC pour GitHub Actions.

### Étape 3 : Environnements Applicatifs (Non-Prod / Prod)
Enfin, vous déployez l'infrastructure de destination (EKS, RDS).
1.  **Déploiement :**
    ```bash
    cd live/nonprod/
    export AWS_PROFILE=aws-nonprod
    terraform init
    terraform apply
    ```

---

## 🔐 3. Configuration GitHub (Variables CI/CD)

Une fois l'infrastructure prête, renseignez les variables dans GitHub (`Settings > Secrets and variables > Actions`) pour permettre au pipeline de déployer l'application.

| Variable | Description |
| :--- | :--- |
| `PROJECT_NAME` | `rhorizon` |
| `AWS_REGION` | `eu-west-1` |
| `ECR_REGISTRY` | URL du registre dans le compte Shared |
| `EKS_CLUSTER_NAME` | Nom du cluster EKS |
| `DOMAIN_NAME` | ex: `nonprod.rhorizon.xyz` |
| `ACM_CERT_ARN` | ARN du certificat SSL |
| `WAF_ACL_ARN` | ARN de la protection WAF |
| `DB_HOST` | Endpoint de la base RDS |
| `DB_NAME` | `rhorizon_dev` |
| `DB_USER` | `dbadmin` |
| `S3_BUCKET_NAME` | Bucket d'assets centralisé |
| `AWS_ROLE_ARN` | Rôle OIDC (Compte Shared) |
| `AWS_NONPROD_ROLE_ARN` | Rôle de déploiement (Compte Non-Prod) |
| `APP_ROLE_ARN` | Rôle IRSA pour l'application |

---

## 🚀 4. Déploiement Applicatif

Le déploiement en **Non-Prod** est 100% automatisé à chaque `push`.

### Déploiement en Production (Activation)
Par défaut, le job de production est désactivé dans `.github/workflows/main.yml`. Pour l'activer :
1.  **Décommentez** le job `deployment-prod` dans le fichier `.github/workflows/main.yml`.
2.  **Configurez l'approbation manuelle :**
    *   Allez dans `Settings > Environments` sur GitHub.
    *   Créez un environnement nommé `PROD`.
    *   Activez **Required reviewers** et ajoutez votre compte. Cela forcera une validation manuelle avant que le déploiement ne commence.
3.  **Variables Prod :** Assurez-vous que les variables `AWS_PROD_ROLE_ARN`, `DOMAIN_PROD_NAME`, etc., sont bien configurées.

### Vérification Manuelle
## 🔄 5. Maintenance
Pour toute modification d'infrastructure, utilisez toujours `terraform apply` depuis le dossier correspondant. Pour l'application, modifiez le code dans `app/` et poussez sur GitHub.
