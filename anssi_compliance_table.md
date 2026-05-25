# 🛡️ Matrice de Conformité ANSSI DevSecOps

Ce document établit la correspondance directe entre les recommandations du guide **ANSSI DevSecOps (v1.0)** et les implémentations techniques réalisées dans le projet **ASD**.

| Recommandation ANSSI | Mise en œuvre technique dans le projet | Composant / Fichier source |
| :--- | :--- | :--- |
| **Tests de sécurité automatisés (SAST/SCA)** | Intégration de scans SAST et SCA dans les pipelines avant tout build. | \`.github/workflows/\` (Bandit, Trivy, Pip-audit) |
| **Tests dynamiques en exécution (DAST)** | Scan dynamique de l'API déployée en Non-Prod pour détecter les failles d'exécution (OWASP ZAP). | \`.github/workflows/backend.yml\` (Job \`dast-scan\`) |
| **Intégrité et Signature des artefacts** | Signature cryptographique des images Docker et vérification d'admission. | **Cosign** (CI/CD) & **Kyverno** (Cluster EKS) |
| **Ségrégation des environnements** | Isolation physique par comptes AWS distincts (Landing Zone). | Architecture multi-comptes (**Root, Shared, Non-Prod, Prod**) |
| **Suppression des secrets statiques** | Utilisation du protocole OIDC pour l'authentification GitHub Actions vers AWS. | \`modules/cicd-infra/oidc\` |
| **Principe du Moindre Privilège** | Rôles IAM granulaires assumés dynamiquement selon l'environnement de déploiement. | \`modules/cicd-infra/target-role\` |
| **Gestion sécurisée des secrets** | Centralisation et isolation des secrets via un service managé chiffré. | **AWS Secrets Manager** (Préfixes par env) |
| **Durcissement des systèmes (OS)** | Utilisation d'images minimales (Distroless/Slim) et exécution sans privilèges root. | \`app/backend/Dockerfile\` (User \`appuser\`) |
| **Gestion rigoureuse des dépendances** | Audit automatique des CVE dans les librairies tierces à chaque commit. | Pipeline Backend (\`pip-audit\`) |
| **Confidentialité de la CI/CD** | Utilisation de runners éphémères et traçabilité totale des accès via CloudTrail. | **OIDC** + **AWS CloudTrail** |
| **Zéro exposition Internet** | Isolation des ressources critiques (EKS/RDS) dans des sous-réseaux privés sans IP publique. | \`modules/core-network/vpc.tf\` |
| **Immutabilité des traces d'audit** | Protection des journaux d'audit contre la suppression et la modification. | **S3 Object Lock** (Mode Compliance) |
| **Conformité de l'Infrastructure (IaC)** | Validation automatique de la sécurité des fichiers Terraform. | \`checkov_scan.md\` |
| **Authentification Forte** | Accès administratif via AWS SSO (Identity Center) avec MFA obligatoire. | \`RUNBOOK.md\` (Configuration Profils SSO) |
| **Cartographie et Analyse** | Documentation exhaustive des flux, des rôles et des risques. | \`cartographie_securite.md\`, \`analyse_risques.md\` |

---

## 📈 Résumé de la posture de sécurité

L'architecture **ASD** a été conçue pour dépasser le simple stade fonctionnel. En alignant chaque brique technique sur les exigences de l'**ANSSI**, nous garantissons :
1.  **L'étanchéité** : Un compromis en Non-Prod ne peut pas impacter la Production.
2.  **La confiance** : Seul le code audité, scanné et signé peut s'exécuter sur le cluster.
3.  **L'auditabilité** : Chaque action est enregistrée de manière indélébile dans un coffre-fort numérique.
