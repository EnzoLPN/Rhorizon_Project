# Scan de Sécurité de l'Infrastructure (Checkov)

Dans le cadre de la démarche **DevSecOps** du projet RHZORION, un scan automatisé de l'infrastructure en tant que code (IaC) a été réalisé à l'aide de l'outil **Checkov**.

## 📊 Résumé du Scan
*   **Total de tests passés** : 244
*   **Total de tests échoués** : 61
*   **Conformité globale** : ~80%

## 🛡️ Analyse des points critiques identifiés

Le scan a identifié plusieurs axes d'amélioration, dont certains sont des choix de conception assumés pour ce prototype, tandis que d'autres feront l'objet d'une remédiation future.

### 1. Identité et Accès (IAM)
*   **Observation** : Certaines politiques IAM pour les rôles GitHub Actions sont jugées trop permissives (usage de l'action `*`).
*   **Justification ASD** : Les rôles sont restreints par des conditions de confiance OIDC, limitant l'usage au dépôt spécifique. Une granularité plus fine sera appliquée en phase de production.

### 2. Sécurité du Cluster EKS (Remédié ✅)
*   **Action réalisée** : L'accès public à l'API Kubernetes a été totalement **désactivé** (\`endpoint_public_access = false\`). L'administration se fait désormais exclusivement via le **bastion SSM** présent dans le VPC.
*   **Logging** : Les 5 types de logs du control plane (API, Audit, Authenticator, etc.) ont été activés pour une traçabilité complète.
*   **Impact** : Élimination de la surface d'attaque externe sur le plan de contrôle Kubernetes.

### 3. Base de Données RDS (Remédié ✅)
*   **Action réalisée** : L'authentification IAM (\`iam_database_authentication_enabled = true\`) a été activée. 
*   **Fonctionnement** : Les applications n'ont plus besoin de stocker un mot de passe en dur. Elles génèrent un jeton d'authentification temporaire via leur rôle IAM pour se connecter à la base.
*   **Sécurité** : Suppression totale des risques liés à la fuite de mots de passe statiques et rotation automatique gérée par IAM.

### 4. Réseau (Security Groups)
*   **Observation** : Le Security Group de l'ALB autorise le port 80 (HTTP).
*   **Justification** : Le port 80 est ouvert uniquement pour effectuer une redirection forcée vers le port 443 (HTTPS), conformément aux standards web actuels.

## 🚀 Conclusion du Scan
La majorité des contrôles de sécurité fondamentaux (chiffrement KMS au repos, isolation des sous-réseaux, immuabilité ECR) sont **validés**. Les points restants concernent principalement le durcissement (hardening) avancé et le monitoring détaillé, qui s'inscrivent dans le cycle d'amélioration continue du projet.

