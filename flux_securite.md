# Matrice de Flux et Groupes de Sécurité (Security Groups)

L'infrastructure RHZORION repose sur une segmentation réseau stricte par **Security Groups (SG)**, agissant comme des pare-feu à état (stateful) au niveau des interfaces réseau (ENI).

## 🛡️ Principes de Filtrage
*   **Principe du moindre privilège** : Seuls les flux strictement nécessaires au fonctionnement des services sont autorisés.
*   **Chaînage de Security Groups** : Au lieu d'utiliser des plages IP (CIDR), les règles utilisent les IDs des SGs sources, garantissant que seule la ressource légitime peut communiquer, même si son IP change.
*   **Egress Control** : Le trafic sortant est restreint vers l'Internet, privilégiant les VPC Endpoints pour les services AWS.

## 📊 Matrice de Flux Inter-Tiers

| Source SG | Destination SG | Port / Protocole | Description |
|-----------|----------------|------------------|-------------|
| **Any (0.0.0.0/0)** | Public ALB | 80/443 (TCP) | Accès utilisateur web (HTTP/HTTPS) |
| **Public ALB** | EKS Nodes (App) | 8080-8443 (TCP) | Transfert du trafic vers les conteneurs |
| **EKS Nodes (App)** | RDS Database | 5432 (TCP) | Accès à la base de données PostgreSQL |
| **EKS Nodes (App)** | Any (0.0.0.0/0) | 53 (UDP/TCP) | Résolution DNS (CoreDNS) |
| **EKS Nodes (App)** | Any (0.0.0.0/0) | 443 (TCP) | Appels API AWS (via NAT ou Endpoints) |

## 🛠️ Détail des Security Groups

### 1. SG-ALB (Load Balancer Public)
*   **Rôle** : Point d'entrée unique de la plateforme.
*   **Entrée** : Autorise HTTP (80) et HTTPS (443) depuis n'importe où.
*   **Sortie** : Restreint aux ports applicatifs du tier EKS uniquement.

### 2. SG-APP (Cluster EKS / Nodes)
*   **Rôle** : Hébergement des micro-services backend et frontend.
*   **Entrée** : Flux limités provenant de l'ALB sur les ports de service. Autorise également les flux internes Kubernetes (CoreDNS).
*   **Sortie** : Limitée à la base de données (5432) et aux services externes essentiels (443 pour les API AWS).

### 3. SG-RDS (Base de Données)
*   **Rôle** : Tier de données persistant.
*   **Entrée** : **Strictement limité** au trafic provenant du SG-APP sur le port 5432. Aucune autre source ne peut interroger la base.
*   **Sortie** : Limitée au sein du VPC uniquement.

