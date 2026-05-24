# Cartographie Applicative & Matrice de Flux (Conformité ANSSI R9)

Ce document dresse la cartographie complète de l'application **RHZORION** et de ses dépendances d'infrastructure, détaillant les droits système, l'inventaire des secrets, les flux réseau et les rôles de gouvernance.

---

## 🔑 1. Cartographie des Droits Système & Privilèges

L'architecture utilise le principe du moindre privilège, matérialisé par des rôles IAM AWS, des politiques d'accès Kubernetes et des mécanismes IRSA (IAM Roles for Service Accounts) :

### A. Rôles IAM CI/CD (GitHub Actions)
| Identité IAM | Contexte d'Utilisation | Droits & Privilèges | Source de Contrôle |
| :--- | :--- | :--- | :--- |
| `shared-github-actions-nonprod-role` | Exécution des tests et déploiement Non-Prod. | - Assumer des rôles uniquement dans le compte `nonprod` (`083127296598`).<br>- Lecture seule ECR. | `modules/cicd-infra/main.tf` |
| `shared-github-actions-prod-role` | Déploiement Production (déclenché depuis la branche `main`). | - Assumer des rôles dans le compte `prod` (`593402827099`).<br>- Administrateur local sur `shared-services`. | `modules/cicd-infra/main.tf` |

### B. Accès d'Administration aux Clusters EKS
| Identité AWS | Niveau d'accès EKS | Description | Mécanisme de contrôle |
| :--- | :--- | :--- | :--- |
| `OrganizationAccountAccessRole` | `AmazonEKSClusterAdminPolicy` | Droits d'administration totale du cluster pour l'équipe DevOps. | EKS Access Entries (`eks-basic`) |
| `shared-github-actions-nonprod-role` | `AmazonEKSClusterAdminPolicy` | Droits de déploiement automatique sur le cluster Non-Prod. | EKS Access Entries (`live/nonprod/main.tf`) |
| `shared-github-actions-prod-role` | `AmazonEKSClusterAdminPolicy` | Droits de déploiement automatique sur le cluster Prod. | EKS Access Entries (`live/prod/main.tf`) |

### C. Droits d'Accès Applicatifs (IRSA)
| Pod / ServiceAccount Kubernetes | Rôle IAM Associé (IRSA) | Privilèges Accordés | Raison d'être |
| :--- | :--- | :--- | :--- |
| `rhorizon-backend-sa` (dans le namespace `rhorizon`) | `rhorizon-[env]-backend-s3-role` | - `s3:GetObject`, `PutObject`, `DeleteObject` sur le bucket d'assets.<br>- `kms:Decrypt`, `GenerateDataKey` sur la clé KMS des assets. | Le backend doit stocker et lire les documents utilisateurs dans le bucket S3 sécurisé. |
| `rhzorion-app-sa` (dans le namespace `default`) | `[env]-eks-secrets-role` | - `secretsmanager:GetSecretValue` sur le chemin `${env}/rhzorion/*`. | Le CSI Driver a besoin de ce rôle pour charger et synchroniser les secrets AWS. |

---

## 🔒 2. Inventaire & Cycle de Vie des Secrets

Aucun secret n'est stocké en dur ou stocké dans les configurations Git.

### A. Secrets de Fonctionnement (AWS Secrets Manager)
| Nom du Secret (AWS) | Portée / Env | Contenu / Clés | Consommateur dans EKS | Type de Stockage |
| :--- | :--- | :--- | :--- | :--- |
| `[env]/rhzorion/app-secrets` | Applicatif | `database_host`, `database_user`, `database_password`, `jwt_secret_key` | Pods backend (via Secrets Store CSI Driver) | Chiffré KMS centralisé |
| Secret GitHub `DB_PASSWORD` | Déploiement | Mot de passe administrateur de la base RDS (PostgreSQL) | Pipeline de déploiement (`deploy.sh`) | Secrets encryptés GitHub |

---

## 🔄 3. Matrice de Flux Réseau & Table de Filtrage (Conformité ANSSI R9)

Les flux réseau sont contrôlés de manière redondante :
1. Au niveau AWS via les **Groupes de Sécurité (Security Groups)**.
2. Au niveau Kubernetes via les **Network Policies**.
3. Au niveau de la périphérie cloud via **AWS WAFv2**.

```
[Utilisateur Externe]
       │ (HTTPS/443)
       ▼
 [AWS WAFv2] (Filtrage)
       │ (HTTPS/443)
       ▼
  [Ingress ALB] (VPC Public)
       │ (HTTP/8080)
       ▼
 [Frontend Pod] (VPC Privé App)
       │ (TCP/5000)
       ▼
  [Backend Pod] ──(TCP/5432)──► [RDS Database] (VPC Privé Data)
       │
       ├─(HTTPS/443)─► [VPC Endpoints / S3 Assets / Secrets Manager]
       └─(HTTPS/443)─► [Amazon ECR]
```

### Matrice Exhaustive des Flux Réseau :
| Source | Destination | Port | Protocole | Rôle / Description | Mécanisme de Filtrage |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **Internet (Utilisateurs)** | **AWS WAFv2** | `80`, `443` | TCP | Requêtes HTTP/HTTPS entrantes du public. | AWS WAFv2 (Filtrage OWASP, Rate Limit, Geo-blocking) |
| **AWS WAFv2** | **Ingress ALB** | `80`, `443` | TCP | Transmission des requêtes validées (propres). | Security Group `alb` (Autorise uniquement le trafic HTTPS clean) |
| **Ingress ALB** | **Frontend Pod** | `8080` | TCP | Redirection du trafic web déchiffré vers Nginx. | Security Group `app` & `NetworkPolicy` (Namespace `rhorizon`) |
| **Ingress ALB** | **Backend Pod** | `5000` | TCP | Redirection directe des requêtes de l'API `/api/*`. | Security Group `app` & `NetworkPolicy` |
| **Frontend Pod** | **Backend Pod** | `5000` | TCP | Appels API internes du code Javascript client vers le Flask Backend. | `NetworkPolicy` (Autorise uniquement si label `app: rhorizon-frontend`) |
| **Backend Pod** | **RDS PostgreSQL** | `5432` | TCP | Connexions et requêtes SQL à la base de données. | Security Group `rds` (Autorise exclusivement le Security Group `app`) |
| **EKS Nodes / Pods** | **AWS Secrets Manager** | `443` | TCP (HTTPS) | Récupération des secrets par le *Secrets Store CSI Driver*. | VPC Endpoint pour Secrets Manager (`com.amazonaws.[region].secretsmanager`) |
| **EKS Nodes / Pods** | **Amazon S3 (Assets)** | `443` | TCP (HTTPS) | Stockage et lecture de documents applicatifs. | VPC Endpoint Gateway S3 (`com.amazonaws.[region].s3`) |
| **EKS Nodes (Workers)** | **Amazon ECR** | `443` | TCP (HTTPS) | Récupération (pull) des images de conteneurs. | VPC Endpoints pour ECR (`ecr.api` & `ecr.dkr`) |
| **EKS Control Plane** | **EKS Nodes (Workers)** | `10250`, `443` | TCP | Communication et pilotage des pods par Kubernetes. | Security Group d'EKS (ENIs cross-account managées par AWS) |
| **Metrics Server / HPA** | **EKS Nodes (Workers)** | `10250`, `443` | TCP | Collecte des métriques CPU/RAM des pods pour l'Auto Scaling. | Security Group d'EKS & `NetworkPolicy` interne |
| **CloudTrail (Master)** | **S3 Audit Logs (Shared)** | `443` | TCP (HTTPS) | Dépôt centralisé des logs d'API de l'organisation. | S3 Bucket Policy (Restreint au principal `cloudtrail.amazonaws.com`) |
| **Bastion / DevOps Admin** | **EKS Nodes / RDS** | `443` | TCP | Session d'administration sécurisée via AWS Systems Manager. | AWS SSM Session Manager (Aucun port ouvert, flux sortant SSM Agent) |

---

## 👥 4. Gouvernance & Droits d'Accès des Développeurs

Pour garantir l'intégrité du code source de bout en bout, le workflow Git respecte les règles suivantes :

1. **Rôles des Développeurs** :
   * **Développeurs (Rôle Read/Write)** : Peuvent créer des branches de fonctionnalités (`feature/*`), pousser des commits signés, et soumettre des Pull Requests.
   * **Relecteurs / Maintainers (Rôle Admin/Maintainer)** : Seuls autorisés à fusionner (merge) le code vers la branche `main` après validation manuelle des tests unitaires et des scans de sécurité (Bandit, Checkov, Trivy).
2. **Politique de Protection de Branche (`main`)** :
   * Approbation par au moins un relecteur obligatoire.
   * Passage obligatoire des vérifications de sécurité dans la CI/CD (y compris le scan des signatures de commits).
   * Interdiction de faire du Force Push.
