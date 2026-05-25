# 🎓 Projet de Fin d'Année - Bachelor : Administrateur Système DevOps (ASD)

## 🚀 Genèse du Projet : La Plateforme RHZORION
Ce dépôt constitue le projet de fin d'études réalisé par **Enzo Loppin & Antimi**. 

À l'origine, ce projet est né d'une volonté de répondre à une problématique industrielle majeure : **Comment déployer une infrastructure SaaS capable d'héberger des données sensibles tout en garantissant une étanchéité totale et une conformité aux standards les plus stricts ?**

Le fruit de cette réflexion est la plateforme **RHZORION**, une architecture "Cloud-Native" conçue dès le premier jour selon les recommandations de l'**ANSSI**. Ce n'est pas seulement un déploiement d'application, c'est un écosystème complet où chaque ressource est isolée, chiffrée et auditée.

## 🏗️ Philosophie de Conception : Modularité & Souveraineté
Dès sa conception, le projet a été bâti sur trois piliers fondamentaux :
*   **Modularité Totale (IaC) :** L'ensemble de l'infrastructure est découpé en modules Terraform indépendants. Cette approche permet de réutiliser ces briques logiques (Réseau, EKS, RDS) pour différents environnements ou clients en garantissant une cohérence parfaite.
*   **Reproductibilité :** L'utilisation de variables dynamiques permet de cloner et redéployer l'intégralité de la Landing Zone de manière automatisée, éliminant les erreurs humaines liées aux configurations manuelles.
*   **Souveraineté des Données :** Utilisation du chiffrement KMS et d'une isolation réseau 3-tiers (Public/Privé/Data) pour garantir le contrôle total sur le cycle de vie des données sensibles.

## 🛠️ Stack Technique & Expertise
*   **Infrastructure as Code :** Architecture multi-comptes AWS pilotée par Terraform (VPC Peering, PrivateLink, KMS).
*   **Orchestration :** Cluster Amazon EKS avec Node Groups privés et sécurisés.
*   **Base de Données :** Amazon RDS PostgreSQL avec authentification IAM (Zéro mot de passe statique).
*   **CI/CD DevSecOps :** Pipeline GitHub Actions automatisé incluant SAST/SCA, scan d'images et signature cryptographique via **Cosign**.
*   **Sécurité Edge :** AWS WAF et certificats SSL gérés pour une exposition sécurisée.

## 📦 Modules Terraform
Ce projet repose sur une bibliothèque de modules personnalisés, conçus pour être évolutifs :

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
Pour comprendre comment initialiser l'Organisation AWS (Compte Master) et déployer cette architecture, consultez le **[RUNBOOK.md](./RUNBOOK.md)**.

---
**Étudiant :** Enzo Loppin & Antimi  
**Promotion :** Bachelor ASD 2026
