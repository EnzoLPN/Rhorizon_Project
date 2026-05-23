# Guide de Test et Déploiement IaC Terraform - RHZORION (ASD)

Ce dépôt contient le code d'infrastructure (Infrastructure as Code) pour la plateforme SaaS **RHZORION** sur AWS, structuré en modules réutilisables et environnements distincts.

---

## 📋 Prérequis Locaux

Avant de commencer les tests, assurez-vous d'avoir installé sur votre machine :
1. **Terraform** (Version `>= 1.5.0`)
2. **AWS CLI v2**

### Configuration des profils AWS SSO
Pour exécuter le code dans chaque compte de manière sécurisée (recommandation ANSSI), vous devez configurer 4 profils de connexion locale via SSO. Exécutez pour chaque compte :
```bash
aws configure sso
```
Configurez-les avec les noms de profils suivants :
*   `aws-master` : Pour le compte d'administration de l'Organisation.
*   `aws-shared` : Pour le compte central `shared-services`.
*   `aws-nonprod` : Pour le compte applicatif `nonprod`.
*   `aws-prod` : Pour le compte applicatif `prod`.

---

## 🛠️ Guide de Test Pas à Pas

### Étape 1 : Initialisation de l'Organisation (`live/global-org`)
Ce module crée la structure d'OUs, les sous-comptes AWS et applique les Service Control Policies (SCPs) globales.

1.  **Connexion AWS** :
    ```bash
    aws sso login --profile aws-master
    ```
2.  **Configuration des variables** :
    *   Allez dans le répertoire : `cd live/global-org/`
    *   Copiez le fichier d'exemple : `cp terraform.tfvars.example terraform.tfvars`
    *   Éditez `terraform.tfvars` et indiquez les adresses e-mail uniques requises par AWS pour vos sous-comptes.
3.  **Test du module** :
    ```bash
    terraform init
    terraform plan
    ```

---

### Étape 2 : Stockage, Chiffrement et ECR Centraux (`live/shared-services`)
Ce module crée les ressources communes et partagées de l'organisation : les buckets S3 d'audit, de sauvegardes et d'assets, les clés de chiffrement KMS, ainsi que le registre de conteneurs privé **shared-ecr** (comprenant les dépôts chiffrés pour le frontend et le backend, configurés en mode tag-immutable avec scan automatique).

1.  **Connexion AWS** :
    ```bash
    aws sso login --profile aws-shared
    ```
2.  **Configuration des variables** :
    *   Allez dans le répertoire : `cd ../shared-services/`
    *   Copiez le fichier d'exemple : `cp terraform.tfvars.example terraform.tfvars`
    *   Éditez `terraform.tfvars` : indiquez le préfixe souhaité pour vos buckets S3 et renseignez les **IDs des comptes nonprod et prod** (générés et affichés à l'Étape 1).
3.  **Test du module** :
    ```bash
    terraform init
    terraform plan
    ```
4.  **Outputs du registre ECR** :
    Une fois le module planifié ou appliqué, vérifiez l'output `ecr_repository_urls` qui listera les adresses de connexion pour pousser vos images de conteneurs (ex: `frontend` et `backend`).

---

### Étape 3 : Réseau Fondateur (`live/nonprod/network` & `live/prod/network`)
Ce module déploie les VPCs isolés en 3 tiers, les NAT Gateways et les VPC Endpoints.

#### Tester l'environnement Non-Prod (np) :
1.  **Connexion AWS** :
    ```bash
    aws sso login --profile aws-nonprod
    ```
2.  **Test du module** :
    *   Allez dans le répertoire : `cd ../nonprod/network/`
    *   Exécutez :
        ```bash
        terraform init
        terraform plan
        ```

#### Tester l'environnement Prod (pr) :
1.  **Connexion AWS** :
    ```bash
    aws sso login --profile aws-prod
    ```
2.  **Test du module** :
    *   Allez dans le répertoire : `cd ../../prod/network/`
    *   Exécutez :
        ```bash
        terraform init
        terraform plan
        ```

---

### Étape 4 : Base de Données RDS PostgreSQL (`live/nonprod/rds` & `live/prod/rds`)
Ce module déploie l'instance de base de données PostgreSQL isolée dans le tier data du VPC.

#### Tester l'environnement Non-Prod (np) :
1.  **Connexion AWS** :
    ```bash
    aws sso login --profile aws-nonprod
    ```
2.  **Configuration des variables** :
    *   Allez dans le répertoire : `cd ../../nonprod/rds/`
    *   Créez un fichier `terraform.tfvars` et renseignez le mot de passe administrateur :
        ```hcl
        db_admin_password = "VotreMotDePasseTresSecurise123!"
        ```
3.  **Test du module** :
    ```bash
    terraform init
    terraform plan
    ```

#### Tester l'environnement Prod (pr) :
1.  **Connexion AWS** :
    ```bash
    aws sso login --profile aws-prod
    ```
2.  **Configuration des variables** :
    *   Allez dans le répertoire : `cd ../../prod/rds/`
    *   Créez un fichier `terraform.tfvars` et renseignez un mot de passe administrateur fort :
        ```hcl
        db_admin_password = "VotreMotDePasseDeProdHyperRobuste987!"
        ```
3.  **Test du module** :
    ```bash
    terraform init
    terraform plan
    ```

---

### Étape 5 : Cluster Kubernetes EKS (`live/nonprod/eks` & `live/prod/eks`)
Ce module déploie le cluster Kubernetes géré, configure le fournisseur OIDC (IRSA) pour la sécurité applicative IAM, et déploie le groupe de nœuds gérés (Managed Node Group) et les add-ons essentiels (EBS CSI pour le stockage, CoreDNS, etc.).

#### Tester l'environnement Non-Prod (np) :
1.  **Connexion AWS** :
    ```bash
    aws sso login --profile aws-nonprod
    ```
2.  **Test du module** :
    *   Allez dans le répertoire : `cd ../../nonprod/eks/`
    *   Exécutez :
        ```bash
        terraform init
        terraform plan
        ```
3.  **Connexion au cluster (après déploiement)** :
    Une fois le cluster créé, configurez votre client local `kubectl` :
    ```bash
    aws eks update-kubeconfig --region eu-west-1 --name nonprod-eks-cluster --profile aws-nonprod
    kubectl get nodes
    ```

#### Tester l'environnement Prod (pr) :
1.  **Connexion AWS** :
    ```bash
    aws sso login --profile aws-prod
    ```
2.  **Test du module** :
    *   Allez dans le répertoire : `cd ../../prod/eks/`
    *   Exécutez :
        ```bash
        terraform init
        terraform plan
        ```
3.  **Connexion au cluster (après déploiement)** :
    ```bash
    aws eks update-kubeconfig --region eu-west-1 --name prod-eks-cluster --profile aws-prod
    kubectl get nodes
    ```

---

### Étape 6 : DNS Public, Certificat SSL ACM et Sécurité WAFv2 (`live/nonprod/dns-ingress` & `live/prod/dns-ingress`)
Ce module provisionne la zone publique Route 53 pour la résolution de noms, demande et valide automatiquement un certificat SSL/TLS ACM wildcard par DNS, et déploie un Web ACL WAFv2 régional (avec Rate Limiting et règles managées) pour protéger notre futur Ingress EKS.

#### Tester l'environnement Non-Prod (np) :
1.  **Connexion AWS** :
    ```bash
    aws sso login --profile aws-nonprod
    ```
2.  **Test du module** :
    *   Allez dans le répertoire : `cd ../../nonprod/dns-ingress/`
    *   Exécutez :
        ```bash
        terraform init
        terraform plan
        ```

#### Tester l'environnement Prod (pr) :
1.  **Connexion AWS** :
    ```bash
    aws sso login --profile aws-prod
    ```
2.  **Test du module** :
    *   Allez dans le répertoire : `cd ../../prod/dns-ingress/`
    *   Exécutez :
        ```bash
        terraform init
        terraform plan
        ```
### Étape 7 : Gestion des Secrets / Secrets Management (`live/nonprod/eks` & `live/prod/eks`)
L'intégration du module **10.9 (Secrets Management)** est couplée aux déploiements EKS. Lors de l'exécution de l'Étape 5 d'EKS, le pilote **Secrets Store CSI Driver** et le **Provider AWS (ASCP)** sont installés automatiquement via Helm dans le cluster. De plus, un rôle IAM (IRSA) et un secret chiffré KMS sont provisionnés dans AWS Secrets Manager.

#### Valider le Secrets CSI (après déploiement EKS) :
1.  **Vérifier que les pods du driver CSI tournent** :
    ```bash
    kubectl get pods -n kube-system -l app.kubernetes.io/name=secrets-store-csi-driver
    ```
2.  **Rôle IAM (IRSA) applicatif** :
    Vérifiez l'output `secrets_role_arn` retourné par Terraform, qui fournit l'ARN du rôle IAM à annoter sur votre Service Account Kubernetes (`rhzorion-app-sa`).

---

### Étape 8 : Observabilité Unifiée - Prometheus, Grafana et Fluent Bit (`live/nonprod/eks` & `live/prod/eks`)
L'observabilité est intégrée aux déploiements de vos clusters EKS. La stack Prometheus/Grafana supervise les métriques système/applicatives (namespace `monitoring`). Le DaemonSet Fluent Bit collecte tous les logs du cluster (namespace `logging`) et les achemine en double flux vers CloudWatch Logs (diagnostic immédiat) et le bucket S3 centralisé d'audit chiffré (archivage).

#### Valider la Stack d'Observabilité :
1.  **Vérifier que les pods de supervision et de logs tournent** :
    ```bash
    kubectl get pods -n monitoring
    ```
    ```bash
    kubectl get pods -n logging
    ```
2.  **Accéder à l'interface Grafana locale via Port-Forward** :
    ```bash
    kubectl port-forward svc/kube-prometheus-stack-grafana 3000:80 -n monitoring
    ```
    Ouvrez `http://localhost:3000` (identifiants d'administration par défaut : `admin` / `prom-operator`).
3.  **Vérifier la transmission des logs** :
    *   **CloudWatch Logs** : Allez sur la console AWS CloudWatch > Log groups et vérifiez la présence du groupe `/eks/rhzorion/<env>/applications`.
    *   **S3 Logs** : Ouvrez le bucket S3 d'audit et vérifiez l'écriture des archives dans le chemin `eks/<env>/`.

---

## 🧹 Nettoyage des ressources (Indispensable)

> [!CAUTION]
> Pour un projet éducatif, afin d'éviter tout dépassement de budget ou frais inutiles sur AWS, exécutez la commande suivante dans chaque répertoire dès que vos tests de validation ou démonstrations sont terminés (commencez par détruire l'EKS, puis la RDS, et enfin le Réseau) :
> ```bash
> terraform destroy
> ```

