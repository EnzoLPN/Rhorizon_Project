# ASD - Architecture Sécurisée & Déploiement

Ce projet implémente une **Landing Zone AWS multi-comptes** hautement sécurisée, conçue selon les recommandations de l'**ANSSI** (guide DevSecOps et isolation des environnements). Il supporte une stack applicative Full-Stack (React/Python) déployée sur **Amazon EKS**.

## 🏗️ Architecture Multi-Comptes

L'infrastructure est segmentée en quatre comptes AWS distincts pour garantir une isolation maximale :

1.  **Compte Master / Root** : Gestion de l'organisation (AWS Organizations) et du SSO.
2.  **Compte Shared-Services** (116101833976) :
    *   **CI/CD Centralisée** : Fournisseur OIDC GitHub et rôles IAM (shared-github-actions-*) pour le déploiement cross-account.
    *   **ECR Centralisé** : Registre Docker immuable avec scan de vulnérabilités (rhzorion/frontend, rhzorion/backend).
    *   **Sécurité Centralisée** : Clés KMS maîtresses, S3 avec **Object Lock** (Immutabilité des logs d'audit).
    *   **DNS Parent** : Zone racine rhorizon.xyz déléguant aux sous-domaines enfants.
3.  **Compte Non-Prod** (083127296598) :
    *   Environnement de développement et staging.
    *   Sous-domaine : nonprod.rhorizon.xyz.
4.  **Compte Prod** (593402827099) :
    *   Environnement de production critique, Multi-AZ et durci par WAF (règles étendues).
    *   Sous-domaine : prod.rhorizon.xyz.

---

## 📂 Structure du Projet

### live/ (Infrastructure par Environnement)
Configurations Terraform appelant les modules :
*   global-org/ : Organisation AWS, OUs et SCP (Service Control Policies).
*   shared-services/ : Ressources partagées (KMS, S3 Logs/Backups, ECR, OIDC).
*   nonprod/ : Stack applicative Non-Prod (VPC, EKS Cluster nonprod-eks-cluster, RDS).
*   prod/ : Stack applicative Prod (VPC HA, EKS Cluster prod-eks-cluster, RDS Multi-AZ).

### modules/ (Composants Réutilisables)
Modules Terraform durcis :
*   core-network/ : VPC, Subnets (Public/Private/Data), NAT GW, Endpoints (PrivatLink en Prod).
*   eks-basic/ : Cluster EKS v1.32 avec **Access Entries** et Managed Node Groups.
*   rds-database/ : PostgreSQL isolé avec chiffrement KMS et Secrets Manager.
*   dns-ingress/ : Route53, ACM (SSL/TLS) et WAFv2.
*   cicd-infra/ : Infrastructure OIDC pour GitHub Actions avec isolation des rôles Non-Prod/Prod.
*   **observability/** : Installation automatisée de Prometheus, Grafana et Fluent Bit via **Helm Release**.

### app/ (Code Applicatif & K8s)
*   backend/ : API Python Flask (Gunicorn, Boto3).
*   frontend/ : Interface React (Vite, Nginx).
*   **k8s/** : Déploiement Kubernetes via CI/CD.
    *   security/ : Admission Control via Kyverno pour la signature d'images.

---

## 🚀 Flux de Déploiement (CI/CD)

1.  **Build & Signature** : GitHub Actions build les images, les scanne avec Trivy et les signe avec **Cosign**.
2.  **Centralisation** : Les images sont stockées dans le compte Shared.
3.  **Déploiement Cross-Account** :
    *   Le runner GitHub assume un rôle dans **Shared**.
    *   Ce rôle assume ensuite un rôle cible dans **Non-Prod** ou **Prod** pour appliquer les changements.
    *   Le déploiement en Production requiert une **approbation manuelle** (GitHub Environments).

---

## 🛡️ Sécurité & Conformité

*   **Isolation Réseau** : Tiers Data (RDS) sans accès internet. Bastion SSM pour l'administration.
*   **Immutabilité** : Object Lock sur S3 pour empêcher la suppression des logs.
*   **Chiffrement** : Tout est chiffré au repos (KMS) et en transit (TLS 1.2+).
*   **Contrôle d'Accès** : EKS Access Entries pour supprimer la ConfigMap vulnérable aws-auth.

---

## 🛠️ Installation

```bash
# 1. Déployer Shared Services
cd live/shared-services && terraform apply

# 2. Déployer l'environnement cible (EKS + Monitoring inclus)
cd ../nonprod && terraform apply
```
