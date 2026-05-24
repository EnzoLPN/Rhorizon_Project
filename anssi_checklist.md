# 🛡️ Démarche de Conformité ANSSI

Le projet **ASD** a été conçu dès le premier jour avec une approche "Security by Design". Notre démarche s'appuie sur le guide des **"Recommandations de sécurité relatives au déploiement de services cloud"** et les principes du **DevSecOps** publiés par l'**ANSSI**.

L'objectif est d'atteindre un niveau de protection robuste pour une infrastructure multi-tenant, en garantissant l'étanchéité des environnements et la traçabilité totale des actions.

---

## ✅ Checklist des Recommandations Appliquées

### 🏗️ Architecture & Gouvernance (R4, R6)
- [x] **Isolation Multi-comptes** (AWS Organizations) : Étanchéité totale entre Master, Shared Services, Non-Prod et Prod.
- [x] **Réseau 3-Tiers** : Séparation physique et logique des flux (Public, Private, Data).
- [x] **Souveraineté des Flux** : Architecture prête pour des runners de CI/CD auto-hébergés si nécessaire.
- [x] **Administration Sécurisée** : Utilisation exclusive d'AWS SSM (Session Manager) pour supprimer tout accès SSH direct.

### 🔑 Gestion des Identités (R11)
- [x] **Moindre Privilège** : Rôles IAM granulaires par environnement et par service.
- [x] **Authentification Moderne (OIDC)** : Suppression des clés d'accès statiques (`Access Keys`) dans la CI/CD via le fournisseur OIDC.
- [x] **SSO (IAM Identity Center)** : Centralisation de l'authentification humaine avec double authentification (MFA).

### 📦 Sécurité des Conteneurs (R2, R8)
- [x] **Chaîne de Confiance (Supply Chain)** : Signature cryptographique des images Docker avec **Cosign**.
- [x] **Admission Control** : Déploiement de **Kyverno** sur EKS pour bloquer les images non signées ou non conformes.
- [x] **Runtime Hardening** : Exécution systématique en mode `non-root` et suppression des capacités Linux inutiles (ALL drops).

### 💾 Protection des Données & Chiffrement (R7)
- [x] **Chiffrement au repos** : 100% des données (S3, RDS, ECR, EBS) sont chiffrées via des clés **AWS KMS** gérées par nous.
- [x] **Chiffrement en transit** : Utilisation forcée de TLS 1.2+ via ACM et Ingress Controller.
- [x] **Secrets Management** : Injection dynamique des secrets via **Secrets Store CSI Driver** (pas de secrets dans les fichiers YAML).

### 🔍 Surveillance & Traçabilité (R12)
- [x] **Audit Immuable** : CloudTrail activé au niveau organisationnel avec stockage sur un bucket S3 **Object Lock** (WORM).
- [x] **Observabilité Unifiée** : Centralisation des logs applicatifs (Fluent Bit) et métriques (Prometheus/Grafana).
- [x] **Détection d'Intrusion** : Analyse en temps réel des flux réseaux via VPC Flow Logs.

---

## 📈 Prochaines Étapes pour le Durcissement
1. **Infrastructure souveraine** : Migration vers des runners de build sur le territoire national.
2. **Audit statique (SAST/DAST)** : Intégration systématique de scans de vulnérabilités dans le pipeline de déploiement.
3. **Zéro Trust** : Mise en place d'un service mesh (Istio) pour le chiffrement mTLS entre les micro-services.
