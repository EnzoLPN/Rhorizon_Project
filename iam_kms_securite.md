# Gestion des Identités (IAM) et du Chiffrement (KMS)

La sécurité de la plateforme RHZORION repose sur une gestion granulaire des droits d'accès et une protection systématique des données au repos via le chiffrement.

## 🔑 Gestion des Identités et des Accès (IAM)

L'architecture IAM suit strictement le principe du **moindre privilège** et favorise l'utilisation d'identités temporaires plutôt que de clés d'accès statiques.

### 🛡️ Concepts Clés
*   **IRSA (IAM Roles for Service Accounts)** : Les applications tournant sur EKS n'utilisent pas les droits des nœuds de calcul. Chaque micro-service possède son propre rôle IAM via un fournisseur OIDC, limitant ainsi l'impact en cas de compromission d'un Pod.
*   **Fédération d'Identité (OIDC)** : Pour le déploiement CI/CD, GitHub Actions utilise des rôles IAM temporaires via OIDC, supprimant le besoin de stocker des `AWS_ACCESS_KEY` dans les secrets GitHub.
*   **Séparation des Privilèges** : Les rôles sont segmentés par fonction (Cluster EKS, Nœuds, Driver CSI, Gestion des Secrets).

### 📊 Principaux Rôles IAM

| Rôle | Portée | Fonction de Sécurité |
|------|--------|----------------------|
| `eks-cluster-role` | EKS Control Plane | Permet à AWS de gérer les ressources réseau et de calcul pour Kubernetes. |
| `eks-node-role` | Worker Nodes | Droits limités pour rejoindre le cluster et tirer des images ECR. |
| `secrets-app-role` | Pods applicatifs | Autorise uniquement la lecture des secrets spécifiques dans Secrets Manager. |
| `fluent-bit-role` | Observabilité | Permet l'envoi sécurisé des logs vers CloudWatch et S3. |
| \`github-actions-role\` | CI/CD (Build/Scan) | Droits limités au push ECR et au scan de vulnérabilités. Aucun droit de modification de l'infrastructure. |


---

## 🔒 Stratégie de Chiffrement (AWS KMS)

Toutes les données sensibles (logs, backups, images, secrets) sont chiffrées avec des **Customer Managed Keys (CMK)**, offrant un contrôle total sur les politiques d'accès.

### 🛡️ Sécurité des Clés
*   **Rotation Automatique** : Les clés KMS sont configurées pour une rotation annuelle automatique des matériaux de clé.
*   **Politiques de Clé (Key Policies)** : L'accès aux clés est restreint au niveau du service AWS et du rôle IAM utilisateur, empêchant même les administrateurs globaux d'accéder aux données sans autorisation spécifique.
*   **Séparation des Tâches** : Des clés distinctes sont utilisées pour les logs, les sauvegardes et les assets afin de compartimenter les risques.

### 🛠️ Utilisation des Clés KMS

| Clé KMS | Usage | Bénéfice Sécurité |
|---------|-------|-------------------|
| **KMS Logs** | CloudWatch, S3 Logs, Flow Logs | Confidentialité des traces d'audit et des journaux applicatifs. |
| **KMS Backups** | Snapshots RDS, S3 Backups | Protection des données de secours contre l'extraction non autorisée. |
| **KMS ECR** | Images Docker | Chiffrement des artefacts logiciels avant déploiement. |
| **KMS Secrets** | Secrets Manager | Sur-chiffrement des mots de passe et clés API en base. |

