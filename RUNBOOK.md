# 📖 Runbook de Déploiement

Ce document guide le déploiement complet de l'infrastructure et de l'application.

## 🛠️ 1. Prérequis

Avant de commencer, assurez-vous d'avoir :

*   **AWS CLI** installé et configuré (de préférence via AWS SSO).
*   **Terraform** (>= 1.9.0) installé.
*   **kubectl** installé.
*   Trois comptes AWS (ou trois profils) :
    *   `shared-services` : Héberge l'OIDC GitHub, ECR et les logs.
    *   `nonprod` : Environnement de test (EKS, RDS).
    *   `prod` : Environnement de production.

## 🏗️ 2. Déploiement Infrastructure (Terraform)

Le déploiement doit se faire dans l'ordre suivant :

### Étape A : Shared Services
1.  Allez dans `live/shared-services/`.
2.  Mettez à jour les variables dans `variables.tf` (ID de comptes, organisation GitHub).
3.  Exécutez :
    ```bash
    terraform init
    terraform apply
    ```
4.  Notez l'ARN du rôle GitHub Actions (`github_actions_nonprod_role_arn`).

### Étape B : Environnement Non-Prod
1.  Allez dans `live/nonprod/`.
2.  Vérifiez que le chemin vers le `remote_state` de shared-services est correct.
3.  Exécutez :
    ```bash
    terraform init
    terraform apply
    ```

## 🔐 3. Configuration GitHub

Dans votre dépôt GitHub, configurez les **Repository Variables** suivantes (`Settings > Secrets and variables > Actions`) :

| Variable | Valeur |
| :--- | :--- |
| `PROJECT_NAME` | Nom du projet (ex: `rhorizon`) |
| `AWS_REGION` | Votre région (ex: `eu-west-1`) |
| `ECR_REGISTRY` | `<ID_ACCOUNT_SHARED>.dkr.ecr.<REGION>.amazonaws.com` |
| `EKS_CLUSTER_NAME` | Nom du cluster (ex: `rhorizon-nonprod-eks-cluster`) |
| `DOMAIN_NAME` | Votre domaine (ex: `nonprod.rhorizon.xyz`) |
| `ACM_CERT_ARN` | ARN du certificat ACM (voir outputs terraform) |
| `WAF_ACL_ARN` | ARN du Web ACL WAF (voir outputs terraform) |
| `DB_HOST` | Endpoint RDS (voir outputs terraform) |
| `DB_NAME` | `rhorizon_dev` |
| `DB_USER` | `dbadmin` |
| `S3_BUCKET_NAME` | Nom du bucket assets (voir outputs terraform) |
| `AWS_ROLE_ARN` | ARN du rôle OIDC dans le compte **Shared** |
| `AWS_NONPROD_ROLE_ARN` | ARN du rôle de déploiement dans le compte **Non-Prod** |

## 🚀 4. Déploiement Applicatif

Le déploiement est automatisé via GitHub Actions lors d'un `push` sur la branche `main`.

### Vérification Manuelle
Si vous souhaitez vérifier le déploiement manuellement :
1.  Connectez-vous au cluster :
    ```bash
    aws eks update-kubeconfig --name <CLUSTER_NAME> --region <REGION> --profile <VOTRE_PROFIL>
    ```
2.  Vérifiez les pods :
    ```bash
    kubectl get pods -n <PROJECT_NAME>
    ```

## 🔄 5. Maintenance et Mise à jour

*   **Mise à jour de l'app :** Poussez simplement votre code, le pipeline s'occupe du build, du scan et du déploiement.
*   **Changement d'infra :** Modifiez les fichiers dans `live/` ou `modules/` et appliquez `terraform apply`.
