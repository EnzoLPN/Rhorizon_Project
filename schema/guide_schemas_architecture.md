# Guide de Conception des Schémas d'Architecture - RHZORION

Ce guide détaille les éléments à faire figurer dans vos deux schémas d'architecture pour documenter précisément la posture DevSecOps du projet **RHZORION**.

---

## 🗺️ Schéma 1 : Macro-Architecture (Landing Zone & Gouvernance)
* **Objectif** : Représenter la structure multi-comptes AWS, les frontières de sécurité de l'organisation et la centralisation des flux transverses.

### 1. Structure Générale (Les Conteneurs de niveau 1)
Dessinez une grande boîte principale représentant l'**AWS Organization**. À l'intérieur, placez 4 grandes boîtes (ou cadres) représentant vos comptes AWS :
*   **Compte Master (Root)**
*   **Compte Shared Services** (Services Partagés)
*   **Compte Non-Prod** (Hors-Production)
*   **Compte Prod** (Production)

### 2. Éléments de Sécurité Globaux (SCPs)
Placez des icônes de bouclier (ou des étiquettes de règle) appliquées à la racine de l'organisation :
*   **SCP 1 : Restriction UE** (Interdiction de déployer hors eu-west-1, eu-central-1, eu-west-2).
*   **SCP 2 : S3 Public Block** (Interdiction de désactiver le blocage de l'accès public S3).
*   **SCP 3 : CloudTrail Protect** (Interdiction d'arrêter ou de modifier la journalisation CloudTrail).

### 3. Composants par Compte
*   **Compte Master** :
    *   Le service **AWS Organizations** (gestion centrale).
    *   La ressource **AWS CloudTrail d'Organisation** (collecteur de logs global).
    *   Une clé **AWS KMS** (chiffrement du Trail).
*   **Compte Shared Services** :
    *   Le bucket **S3 centralisé de logs d'audit** (`rhorizon-monprojet-audit-logs`) configuré avec **S3 Object Lock** (rétention 90 jours).
    *   Le registre **Amazon ECR** (contenant les images du backend et du frontend).
    *   Les deux rôles OIDC séparés : `shared-github-actions-nonprod-role` et `shared-github-actions-prod-role`.
*   **Comptes Applicatifs (Non-Prod & Prod)** :
    *   Représentez-les de manière simplifiée dans ce schéma : une boîte VPC contenant un cluster EKS et une base de données RDS.
    *   Montrez le rôle IAM local qui est assumé par la CI/CD (`github_actions_nonprod` / `github_actions_prod`).

### 4. Les Flux Transversaux à tracer (Flèches)
*   **Flux de Logs** : Du *CloudTrail d'Organisation* (compte Master) vers le *bucket S3 d'audit* (compte Shared Services).
*   **Flux de Déploiement** :
    *   GitHub Actions s'authentifie en OIDC sur les rôles de `shared-services`.
    *   Les rôles de `shared-services` effectuent un `AssumeRole` cross-account vers les comptes cibles (`nonprod` ou `prod`) pour y déployer.
*   **Flux d'images Docker** : Les clusters EKS de Non-Prod et Prod récupèrent les images conteneurs (ECR Pull) depuis le compte central `shared-services`.

---

## 🖥️ Schéma 2 : Micro-Architecture (Réseau & EKS du compte Prod)
* **Objectif** : Représenter le cloisonnement réseau (Multi-AZ), la haute disponibilité, et la topologie des ressources Kubernetes dans le compte de Production.

### 1. La Topologie Réseau (AWS) et le comportement Multi-AZ
*   **Le VPC** : Dessinez le cadre du VPC (IP : `10.20.0.0/16`).
*   **Les zones de disponibilité (AZ)** : Divisez le VPC verticalement en **3 colonnes** (AZ A, AZ B, AZ C) pour illustrer la haute disponibilité physique (Multi-AZ).
*   **Le découpage en sous-réseaux (Subnets)** : Dans chaque AZ, dessinez 3 couches de sous-réseaux (de haut en bas) :
    1.  **Sous-réseau Public** :
        *   Contient les **NAT Gateways** (qui permettent aux ressources privées de sortir sur Internet).
        *   Contient les **nœuds de l'Application Load Balancer (ALB)**. *Note d'architecture* : AWS déploie automatiquement un nœud ALB redondant dans chaque sous-réseau public de chaque AZ. Route 53 distribue le trafic entrant de manière équitable entre ces nœuds.
    2.  **Sous-réseau Privé Applicatif** :
        *   Contient les nœuds workers EKS du cluster. Les instances EC2 de votre EKS Node Group sont réparties par AWS sur les 3 AZs.
    3.  **Sous-réseau Privé Isolés (Data)** :
        *   Contient la base de données RDS PostgreSQL.


### 2. Le Cluster EKS (Kubernetes) - L'imbrication Visuelle des Boîtes
Pour représenter proprement Kubernetes, dessinez les éléments sous forme de boîtes imbriquées dans vos sous-réseaux privés applicatifs :

*   **Le cadre global "Cluster EKS (Data Plane)"** : Un grand rectangle qui englobe les sous-réseaux privés applicatifs des 3 AZs.
*   **Les "Workers Nodes" (Instances EC2)** : Dessinez un bloc machine EC2 physique dans chacun des sous-réseaux privés des 3 AZs.
*   **Le cadre logique "Namespace: rhorizon"** : Dessinez un rectangle de couleur distincte qui traverse les Workers des 3 AZs. Il représente le cloisonnement logique de votre application.
*   **Les composants dans le Namespace `rhorizon`** :
    *   **L'Ingress (AWS Load Balancer Controller)** : Reçoit le trafic HTTPS de l'ALB public et le distribue aux **Services** Kubernetes.
    *   **Le Service `frontend`** (Routage virtuel) ──> redirige vers les **Pods Frontend (Nginx)**.
    *   **Le Service `backend`** (Routage virtuel) ──> redirige vers les **Pods Backend (Flask API)**.
    *   **Pods Frontend (AZ A & B / répliqués)** : Nginx durci (`runAsNonRoot: true`, `readOnlyRootFilesystem: true`) avec un montage de volume temporaire `emptyDir` pour stocker les caches Nginx.
    *   **Pods Backend (AZ A & B / répliqués)** : Flask API durci, connecté à un volume virtuel **Secrets Store CSI Driver** qui monte les identifiants de la base de données en mémoire.
    *   **L'Autoscaler (HPA)** : Représentez-le connecté aux Déploiements Frontend et Backend. Il surveille le CPU des pods (via le Metrics Server d'EKS) et fait varier dynamiquement le nombre de pods de 2 à 5.
*   **La Sécurité d'Admission (Kyverno)** :
    *   Dessinez le composant **Kyverno (Admission Controller)** à cheval entre l'**EKS Control Plane** (qui envoie les requêtes d'API d'administration) et le **Data Plane** (les Nodes).
    *   Montrez que Kyverno intercepte la création de pods pour vérifier que la signature de l'image sur ECR correspond à notre clé Cosign publique.


### 3. La Base de Données (RDS Multi-AZ)
*   Dans le sous-réseau Data privé, placez l'instance de base de données **RDS PostgreSQL**.
*   **Comportement Multi-AZ (Strictement 2 AZs)** : 
    *   Bien que votre VPC et votre cluster EKS soient répartis sur 3 AZs (AZ A, B et C) pour optimiser la tolérance aux pannes réseau et CPU, la base de données RDS en mode Multi-AZ standard n'utilise que **2 AZs**.
    *   Représentez l'instance **Primaire active dans l'AZ A**.
    *   Représentez l'instance **Secondaire (Standby) passive dans l'AZ B**, avec une flèche de réplication synchrone partant de l'AZ A vers l'AZ B.
    *   **L'AZ C ne contient aucune ressource RDS** (le sous-réseau de données de l'AZ C reste vide).


### 4. La Gestion des Secrets
*   Placez l'icône **AWS Secrets Manager** à l'extérieur du VPC.
*   Montrez le flux : Le pod Backend utilise le **Secrets Store CSI Driver** pour récupérer de manière sécurisée les identifiants de la base de données depuis Secrets Manager, les injectant directement en mémoire sans écriture sur le disque.

### 5. Les Flux Réseau à tracer (Flèches) - Le Cheminement Étape par Étape
Dessinez les flèches du trafic entrant de cette façon :

1.  **Client (Internet)** ──> **Route 53 (DNS)** : Résolution DNS du domaine.
2.  **Client (Internet)** ──> **AWS WAFv2 (En dehors du VPC)** : 
    *   *Note d'architecture* : Le WAF est un service managé régional d'AWS situé **hors du VPC**. Il intercepte et analyse le trafic HTTP/HTTPS en amont (filtrage OWASP Top 10, XSS, SQLi, Rate Limiting).
    *   Si la requête est suspecte, elle est rejetée directement (HTTP 403) sans jamais pénétrer votre réseau privé.
3.  **AWS WAFv2** ──(Requête validée)──> **ALB (Application Load Balancer)** :
    *   L'ALB est positionné à la frontière, avec des interfaces réseau dans les **sous-réseaux publics** de votre VPC. Il effectue la terminaison TLS (déchiffrement HTTPS).
4.  **ALB** ──> **Service Frontend (Kubernetes)** ──> **Pods Frontend (Nginx)** :
    *   Le trafic propre est routé vers les nœuds EKS situés dans les **sous-réseaux privés applicatifs**.
5.  **Pods Frontend** ──> **Service Backend (Kubernetes)** ──> **Pods Backend (Flask API)** :
    *   Communication inter-services isolée au sein du réseau privé Kubernetes.
6.  **Pods Backend** ──> **Base de données RDS (PostgreSQL)** :
    *   Flux réseau descendant vers le **sous-réseau Data privé (isolé)**, sécurisé par le Security Group de la base qui n'accepte de trafic que depuis le Security Group d'EKS.
7.  **Pods Backend** ──> **AWS S3 VPC Endpoint (Gateway)** ──> **Bucket d'assets** :
    *   Le trafic vers S3 reste à 100 % au sein du réseau privé AWS grâce au VPC Endpoint, sans sortir sur le réseau internet public.


---

## 🚀 Schéma 3 : Le Pipeline CI/CD DevSecOps
* **Objectif** : Représenter les étapes séquentielles de sécurité traversées par le code, depuis le commit du développeur jusqu'au déploiement validé sur EKS.

### 1. La Ligne de Vie (Pipeline Sequentiel)
Dessinez un flux horizontal (ou un diagramme d'activité de gauche à droite) avec les étapes majeures suivantes :

#### Étape A : Git & Signature (Commit Gate)
*   **Composants** : Développeur -> Commit -> Pull Request (GitHub).
*   **Contrôle de Sécurité** : Workflow **check-signed-commits.yml** qui valide la signature cryptographique (GPG/SSH/1Password) du commit. Si non signé, le pipeline s'arrête immédiatement.

#### Étape B : Scans de Sécurité Statique (Code & IaC)
*   **Contrôles exécutés en parallèle** :
    *   **Checkov** : Scan des fichiers Terraform (bloquant en production en cas de mauvaise conformité).
    *   **Bandit** : Scan SAST (Static Application Security Testing) pour détecter les failles dans le code Python du backend.
    *   **Pip-Audit** : Scan SCA (Software Composition Analysis) pour détecter les dépendances vulnérables déclarées dans `requirements.txt`.
    *   **Trivy (FS)** : Scan du système de fichiers statiques du frontend.

#### Étape C : Compilation & Signature (Artifact Integrity)
*   **Composant** : Construction de l'image Docker (Frontend / Backend).
*   **Contrôle de Sécurité** : Signature cryptographique de l'image compilée à l'aide de **Cosign** (via une clé privée hébergée dans les secrets GitHub).
*   **Publication** : Pousser l'image signée sur le registre privé **Amazon ECR** (compte Shared Services).

#### Étape D : Audit de l'Image Conteneur
*   **Contrôle de Sécurité** : Scan de l'image ECR via **Trivy Image Scan** pour identifier les vulnérabilités de l'OS du conteneur (CVE) avant son déploiement.

#### Étape E : Authentification et Déploiement Cloud (Séparation OIDC par Branche)
*   **Composant** : GitHub Actions Runner -> Échange OIDC avec **AWS IAM Identity Provider**.
*   **Ségrégation stricte selon la Branche (ANSSI R4)** :
    *   **Trajectoire 1 (Branche `main`)** : Le pipeline utilise le rôle IAM **`shared-github-actions-prod-role`** (restreint à la branche main protégée). Il effectue un `AssumeRole` cross-account uniquement vers le compte **Prod** pour déployer sur le cluster EKS de Production (`prod-eks-cluster`).
    *   **Trajectoire 2 (Branches `dev` / `feature/*` / PRs)** : Le pipeline utilise le rôle IAM **`shared-github-actions-nonprod-role`**. Il effectue un `AssumeRole` uniquement vers le compte **Non-Prod** pour déployer sur le cluster EKS de Non-Production (`nonprod-eks-cluster`). Il est techniquement impossible pour cette trajectoire de modifier la Production.
*   **Déploiement** : Utilisation du script `deploy.sh` (qui sécurise le chargement des secrets et interpole les manifestes via `envsubst`) pour appliquer la configuration (`kubectl apply`).


#### Étape F : Contrôle d'Admission & Lancement (Kubernetes)
*   **Composants** : Cluster EKS -> **Admission Controller Kyverno**.
*   **Contrôle de Sécurité** : Kyverno intercepte l'appel de déploiement et vérifie la signature de l'image ECR à l'aide de la clé publique Cosign.
    *   *Si l'image est signée* : Autoriser le déploiement sur les pods en lecture seule (`readOnlyRootFilesystem`).
    *   *Si l'image n'est pas signée* : Bloquer le déploiement et rejeter la requête d'admission.

