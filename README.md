# 🎓 Projet de Fin d'Année - Bachelor : Administrateur Systeme Devops (ASD)

## 🌟 Présentation du Projet
Ce dépôt constitue le projet final de Bachelor, réalisé par **Enzo, Loppin et Antimi**. 

L'objectif de ce projet est de concevoir et déployer une **Landing Zone AWS industrielle**, hautement sécurisée et entièrement modulaire. Il ne s'agit pas seulement d'un déploiement applicatif, mais d'une démonstration de maîtrise de l'infrastructure moderne (IaC), de la sécurité Cloud (conformité ANSSI) et de l'orchestration de conteneurs à l'échelle.

## 🏗️ Philosophie du Projet : Modularité & Scalabilité
La force de cette architecture réside dans sa **conception modulaire** :
*   **Modules Terraform Agnostiques :** Chaque composant (Réseau, EKS, RDS, ECR) est encapsulé dans un module réutilisable, permettant une portabilité entre environnements.
*   **Approche Multi-Comptes :** Isolation stricte des responsabilités (Shared Services, Non-Prod, Prod) pour limiter le rayon d'impact en cas d'incident.
*   **Déploiement Unifié :** Transition d'une architecture multi-conteneurs vers un monolithe unifié (Nginx + Gunicorn) pour optimiser les ressources tout en conservant une séparation logique des services.

## 🛠️ Stack Technique & Expertise
*   **Infrastructure :** Terraform (Multi-comptes AWS), VPC Peering/Transit, KMS Encryption.
*   **Orchestration :** Amazon EKS (Kubernetes 1.32) avec Node Groups privés.
*   **Backend & Front :** Python (Flask/Gunicorn) & Nginx, conteneurisés et sécurisés.
*   **CI/CD :** Pipeline GitHub Actions automatisé (Build, Scan de vulnérabilités, Signature Cosign, Déploiement).
*   **Sécurité :** Authentification IAM pour RDS, WAF v2, Secrets Manager, Isolation réseau totale.

## 🛡️ Conformité & Sécurité
Le projet a été conçu selon les meilleures pratiques de sécurité :
*   **Zero Trust :** Aucun service n'est exposé sans filtrage (ALB/WAF).
*   **Principe de moindre privilège :** Rôles IAM IRSA granulaires pour chaque Pod et utilisateur non-root pour les conteneurs.
*   **Auditabilité :** Centralisation des logs S3 et chiffrement systématique des données au repos.

## 📦 Modules Terraform
Ce projet est construit sur une bibliothèque de modules personnalisés, documentés automatiquement via `terraform-docs` :

| Module | Description | Documentation |
| :--- | :--- | :--- |
| **Accounts Baseline** | Gouvernance (OU, Comptes, SCP, CloudTrail) | [Consulter](./modules/accounts-baseline/README.md) |
| **Core Network** | Fondation réseau (VPC, Subnets, NAT) | [Consulter](./modules/core-network/README.md) |
| **EKS Basic** | Cluster EKS, Node Groups & IAM Access | [Consulter](./modules/eks-basic/README.md) |
| **RDS Database** | Instance PostgreSQL sécurisée | [Consulter](./modules/rds-database/README.md) |
| **Shared ECR** | Registre de conteneurs centralisé | [Consulter](./modules/shared-ecr/README.md) |
| **DNS & Ingress** | Exposition (Route53, ACM, WAF) | [Consulter](./modules/dns-ingress/README.md) |
| **CI/CD Infra** | Fédération OIDC & Rôles GitHub | [Consulter](./modules/cicd-infra/README.md) |
| **Observability** | Monitoring (Prometheus, Grafana) | [Consulter](./modules/observability/README.md) |
| **Secrets Management** | Intégration Secrets Manager & EKS | [Consulter](./modules/secrets-management/README.md) |
| **SSM Bastion** | Accès privé sécurisé (via SSM) | [Consulter](./modules/ssm-bastion/README.md) |
| **Shared Core** | Socle S3 et clés KMS partagées | [Consulter](./modules/shared-core/README.md) |
| **AWS LB Controller** | Gestionnaire Ingress ALB | [Consulter](./modules/aws-load-balancer-controller/README.md) |

## 🚀 Déploiement
Pour comprendre comment mettre en place cette infrastructure de zéro, consultez le **[RUNBOOK.md](./RUNBOOK.md)**.

---
**Étudiants :** Enzo, Loppin, Antimi  
**Promotion :** Bachelor ASD 2025
