# 🚀 Projet ASD - Landing Zone & App Sécurisée (EKS)

Bienvenue sur le projet **ASD (Architecture de Services Déployés)**. Ce dépôt contient une infrastructure complète de type "Landing Zone" sur AWS, ainsi qu'une application unifiée (Frontend + Backend) déployée sur un cluster EKS sécurisé.

## 🏗️ Architecture du Projet

Le projet repose sur une architecture multi-comptes et une gestion d'infrastructure moderne :

*   **Infrastructure as Code (IaC) :** Terraform (Multi-comptes AWS).
*   **Orchestration :** Amazon EKS (Kubernetes) avec des noeuds privés.
*   **Base de Données :** Amazon RDS (PostgreSQL) avec authentification IAM.
*   **Sécurité :** AWS WAF, KMS (Chiffrement au repos), OIDC pour CI/CD, et principes de privilège minimal (Non-root).
*   **Réseau :** VPC avec sous-réseaux privés, Application Load Balancer (ALB) et Route 53.
*   **CI/CD :** GitHub Actions avec déploiement automatique vers ECR et EKS.

## 📁 Structure du Dépôt

```text
.
├── app/               # Code de l'application unifiée (Python/Nginx) et manifests K8s
├── live/              # Configuration Terraform par environnement (shared, nonprod, prod)
├── modules/           # Modules Terraform réutilisables (Network, EKS, RDS, ECR, etc.)
├── README.md          # Présentation du projet
└── RUNBOOK.md         # Guide technique de déploiement et prérequis
```

## 🛡️ Fonctionnalités de Sécurité (Conformité ANSSI)

*   **Zéro Exposition Publique :** Le cluster EKS et la base RDS sont dans des sous-réseaux privés sans accès direct depuis Internet.
*   **Authentification Forte :** Utilisation de l'authentification IAM pour la base de données (pas de mots de passe statiques).
*   **Sécurité des Conteneurs :** Images basées sur Debian Slim, exécution en mode non-root, et scan Trivy/Bandit dans le pipeline.
*   **Protection Web :** WAF configuré sur l'Ingress pour bloquer les attaques courantes (SQLi, XSS).
*   **Gestion des Secrets :** Utilisation d'AWS Secrets Manager pour les données sensibles.

## 🚀 Commencer

Pour déployer ce projet, veuillez vous référer au fichier **[RUNBOOK.md](./RUNBOOK.md)** qui détaille toutes les étapes de configuration et de déploiement.

---
*Projet réalisé dans le cadre de la formation ASD.*
