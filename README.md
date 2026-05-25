# 🎓 Projet de Fin d'Année - Bachelor : Administrateur Système DevOps (ASD)

## 🚀 Genèse du Projet : La Plateforme RHZORION
Ce dépôt constitue le projet de fin d'études réalisé par **Enzo Loppin & Antimi**. 

À l'origine, ce projet est né d'une volonté de répondre à une problématique industrielle majeure : **Comment déployer une infrastructure SaaS capable d'héberger des données sensibles tout en garantissant une étanchéité totale et une conformité aux standards les plus stricts ?**

Le fruit de cette réflexion est la plateforme **RHZORION**, une architecture "Cloud-Native" conçue dès le premier jour sur les recommandations de l'**ANSSI**. Ce n'est pas seulement un déploiement d'application, c'est un écosystème complet où chaque ressource est isolée, chiffrée et auditée.

## 🏗️ Philosophie de Conception : Modularité & Souveraineté
Dès sa conception, le projet a été bâti sur trois piliers fondamentaux :
*   **Modularité Totale :** L'ensemble de l'infrastructure est découpé en modules Terraform agnostiques. Cela permet de réutiliser ces briques (Réseau, EKS, RDS) pour d'autres projets ou clients en quelques minutes.
*   **Reproductibilité :** Grâce à une gestion dynamique des variables, l'intégralité de la Landing Zone peut être clonée et redéployée de manière identique pour un nouvel environnement.
*   **Souveraineté des Données :** Utilisation intensive du chiffrement KMS et de l'isolation réseau 3-tiers (Public/Privé/Data) pour garantir qu'aucune donnée sensible ne puisse sortir de son périmètre défini.

## 🛠️ Stack Technique & Expertise
*   **Infrastructure (IaC) :** Terraform (Multi-comptes AWS), VPC Peering, Transit Gateway, KMS Encryption.
*   **Orchestration :** Amazon EKS (Kubernetes 1.32) avec des Node Groups privés et sécurisés.
*   **Base de Données :** Amazon RDS PostgreSQL avec **Authentification IAM** (Zéro mot de passe statique).
*   **CI/CD DevSecOps :** Pipeline GitHub Actions automatisé incluant :
    *   **SAST/SCA :** Bandit et Pip-audit pour l'analyse de code.
    *   **Supply Chain Security :** Signature d'images Docker avec **Cosign**.
*   **Sécurité Edge :** AWS WAF v2 et CloudFront pour la protection contre les attaques applicatives.

## 📦 Modules Terraform
Ce projet est construit sur une bibliothèque de modules personnalisés, documentés automatiquement :

| Module | Rôle Technique | Documentation |
| :--- | :--- | :--- |
| **Accounts Baseline** | Gouvernance, OU et Service Control Policies (SCP) | [Consulter](./modules/accounts-baseline/README.md) |
| **Core Network** | Fondation réseau isolée (VPC 3-tiers, NAT, DNS) | [Consulter](./modules/core-network/README.md) |
| **EKS Basic** | Cluster Kubernetes durci et Provider OIDC | [Consulter](./modules/eks-basic/README.md) |
| **RDS Database** | Base de données PostgreSQL non-routable | [Consulter](./modules/rds-database/README.md) |
| **Shared ECR** | Registre centralisé et signature d'images | [Consulter](./modules/shared-ecr/README.md) |
| **DNS & Ingress** | Exposition sécurisée (Route53, ACM, WAF) | [Consulter](./modules/dns-ingress/README.md) |
| **CI/CD Infra** | Fédération d'identité OIDC (Passwordless CI) | [Consulter](./modules/cicd-infra/README.md) |
| **Observability** | Monitoring Prometheus/Grafana et Logs centralisés | [Consulter](./modules/observability/README.md) |

## 🚀 Guide de Déploiement
Pour comprendre comment initialiser l'Organisation AWS (Compte Master) et déployer cette architecture de zéro, consultez le **[RUNBOOK.md](./RUNBOOK.md)**.

---
**Étudiants :** Enzo Loppin & Antimi  
**Promotion :** Bachelor ASD 2026
