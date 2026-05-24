# 🚀 Projet ASD : Architecture de Sécurité Distribuée

## 📌 Présentation Générale
Le projet **ASD** (Architecture de Sécurité Distribuée) est une plateforme SaaS moderne et hautement sécurisée déployée sur **AWS**. Développé dans le cadre d'un **projet de fin d'année**, ce travail vise à démontrer la mise en œuvre concrète d'une infrastructure "Cloud-Native" respectant les standards de sécurité les plus exigeants, notamment les recommandations de l'**ANSSI**.

**Équipe :** Enzo Loppin & Antimi

---

## 🏗️ Philosophie du Projet
Dès sa conception, le projet a été bâti sur deux piliers fondamentaux :
*   **Modularité** : L'ensemble de l'infrastructure est découpé en modules Terraform indépendants et réutilisables.
*   **Reproductibilité** : Grâce à une gestion dynamique des variables (notamment le nom du projet), l'intégralité de la Landing Zone et de la stack applicative peut être redéployée en quelques minutes pour un nouveau client ou un nouvel environnement.

---

## 🏗️ Architecture de la Landing Zone
Nous avons implémenté une **Landing Zone multi-comptes** pour garantir une isolation totale des ressources et des responsabilités :

1.  **Compte Master** : Gouvernance de l'organisation AWS et gestion des accès (SSO).
2.  **Compte Shared Services** : Centre névralgique partagé (Registres ECR, DNS parent, stockage centralisé des logs et sauvegardes).
3.  **Compte Non-Prod** : Environnement de développement et de tests (Staging).
4.  **Compte Prod** : Environnement de production hautement disponible et durci.

---

## 🛡️ Les Piliers de Sécurité (Conformité ANSSI)
Consultez notre **[Checklist de Conformité ANSSI détaillée](./anssi_checklist.md)** pour voir l'ensemble des points de contrôle implémentés.

### 1. Isolation & Moindre Privilège (R4, R11)
*   **Architecture Réseau 3-Tiers** : Le VPC est découpé en trois zones d'isolation logique :
    *   **Tier Public** : Reçoit uniquement l'Ingress ALB et les NAT Gateways. Aucune ressource applicative n'est exposée ici.
    *   **Tier Privé** : Héberge le cluster EKS. Les pods sont isolés d'internet et ne peuvent communiquer vers l'extérieur que via les NAT Gateways.
    *   **Tier Data** : Zone ultra-isolée sans aucune route vers internet, dédiée exclusivement à la base de données RDS PostgreSQL.
*   Authentification **OIDC** pour la CI/CD (GitHub Actions) sans clés statiques. Les pipelines sont limités au build et scan des images.
*   **Souveraineté de l'Infrastructure** : Le déploiement IaC est volontairement exclu de la CI/CD pour prévenir les supply-chain attacks. L'administration se fait exclusivement via un **SSM Bastion Host** sécurisé (pas de ports SSH ouverts).

### 2. Sécurité Applicative & Conteneurs (R2, R8)
*   **Signature des images** : Toutes les images Docker sont signées avec **Cosign**.
*   **Contrôle d'admission** : Utilisation de **Kyverno** pour bloquer toute image non signée dans le cluster.
*   **Runtime Security** : Les conteneurs s'exécutent en mode non-root avec des privilèges restreints.

### 3. Protection des Données (R7)
*   Chiffrement intégral au repos et en transit via **AWS KMS**.
*   **Object Lock** (WORM) sur les logs d'audit pour garantir leur intégrité légale.
*   Base de données **RDS PostgreSQL** isolée dans des sous-réseaux non-routables.

---

## 📊 Observabilité & Résilience
*   **Supervision** : Stack Prometheus & Grafana pour le monitoring en temps réel.
*   **Logs Centralisés** : Collecte via Fluent Bit vers CloudWatch et archivage longue durée sur S3.
*   **Haute Disponibilité** : Déploiement Multi-AZ en production pour garantir la continuité de service.

---

## 🛠️ Stack Technique
*   **Infrastructure** : Terraform (IaC)
*   **Cloud** : Amazon Web Services (AWS)
*   **Orchestration** : Kubernetes (Amazon EKS)
*   **Base de données** : PostgreSQL (Amazon RDS)
*   **Sécurité** : WAF v2, KMS, Secrets Manager, Kyverno, Cosign
*   **CI/CD** : GitHub Actions
