# Architecture de l'Infrastructure avec Terragrunt (RHZORION)

Ce document décrit l'organisation et le fonctionnement de l'infrastructure-as-code (IaC) de la plate-forme RHZORION suite à sa migration vers **Terragrunt**.

---

## 1. Arborescence du Projet

Suite au nettoyage des anciens fichiers `.tf` redondants et au découpage d'EKS, voici la nouvelle structure sous `live/` :

```text
live/
├── terragrunt.hcl             # Configuration racine commune (AWS Provider & Backend local)
├── env.hcl                    # Fichier inexistant ici (chaque sous-dossier env en possède un)
│
├── global-org/
│   ├── env.hcl                # AWS Profile 'aws-master'
│   └── terragrunt.hcl         # Instancie 'modules/accounts-baseline'
│
├── shared-services/
│   ├── env.hcl                # AWS Profile 'aws-shared'
│   ├── main.tf                # Orchestre les modules partagés (ECR, KMS, OIDC GitLab)
│   ├── variables.tf           # Variables déclarées
│   ├── outputs.tf             # Outputs de shared services
│   └── terragrunt.hcl         # Fichier Terragrunt pour injecter les variables de shared-services
│
├── nonprod/
│   ├── env.hcl                # AWS Profile 'aws-nonprod', Region 'eu-west-1'
│   ├── network/
│   │   └── terragrunt.hcl     # Instancie 'modules/core-network'
│   ├── rds/
│   │   └── terragrunt.hcl     # Instancie 'modules/rds-database' (Dépend de network)
│   ├── eks-cluster/
│   │   └── terragrunt.hcl     # Instancie 'modules/eks-basic' (Dépend de network)
│   ├── secrets-management/
│   │   └── terragrunt.hcl     # Instancie 'modules/secrets-management' (Dépend de eks-cluster & shared)
│   ├── dns-ingress/
│   │   └── terragrunt.hcl     # Instancie 'modules/dns-ingress'
│   └── observability/
│       └── terragrunt.hcl     # Instancie 'modules/observability' (Dépend de eks-cluster, shared, dns-ingress)
│
└── prod/
    ├── env.hcl                # AWS Profile 'aws-prod', Region 'eu-west-1'
    ├── network/
    │   └── terragrunt.hcl     # Même logique que nonprod avec des inputs de Production
    ├── rds/
    │   └── terragrunt.hcl     # Idem
    ├── eks-cluster/
    │   └── terragrunt.hcl     # Idem
    ├── secrets-management/
    │   └── terragrunt.hcl     # Idem
    ├── dns-ingress/
    │   └── terragrunt.hcl     # Idem
    └── observability/
        └── terragrunt.hcl     # Idem
```

---

## 2. Configuration Terragrunt Racine (`live/terragrunt.hcl`)

Ce fichier centralise la plomberie Terraform pour l'ensemble du dépôt :

```hcl
locals {
  # Charge dynamiquement le profil et la région depuis le "env.hcl" le plus proche
  env_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  
  aws_profile = local.env_vars.locals.aws_profile
  aws_region  = local.env_vars.locals.aws_region
}

# Génère dynamiquement le fichier provider.tf dans chaque sous-dossier lors du run
generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
provider "aws" {
  region  = "${local.aws_region}"
  profile = "${local.aws_profile}"
}

variable "aws_region" {
  type        = string
  description = "Region AWS pour le composant"
  default     = "${local.aws_region}"
}

variable "aws_profile" {
  type        = string
  description = "Profil local AWS CLI SSO"
  default     = "${local.aws_profile}"
}
EOF
}

# Centralise et isole la gestion du state local dans chaque sous-dossier
remote_state {
  backend = "local"
  generate = {
    path      = "backend_override.tf"
    if_exists = "overwrite_terragrunt"
  }
  config = {
    path = "${get_terragrunt_dir()}/terraform.tfstate"
  }
}
```

---

## 3. Exemples de Fichiers Terragrunt

### A. Sans dépendance (`live/nonprod/network/terragrunt.hcl`)
Ce fichier configure simplement le module réseau :
```hcl
include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "../../../modules/core-network"
}

inputs = {
  environment              = "nonprod"
  vpc_cidr                 = "10.10.0.0/16"
  az_count                 = 2
  subnet_cidr_mask         = 24
  nat_strategy             = "single"
  flow_logs_retention_days = 14
  enable_phz              = true
  private_domain_name      = "np.rhorizon.local"
  enable_vpc_endpoints     = false
}
```

### B. Avec dépendances et Mocks (`live/nonprod/observability/terragrunt.hcl`)
Ce fichier utilise les outputs d'autres stacks et gère les simulations (*mocks*) pour le premier déploiement :
```hcl
include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "../../../modules/observability"
}

dependency "eks" {
  config_path = "../eks-cluster"
}

dependency "shared" {
  config_path = "../../shared-services"
}

# Dépendance DNS pour Grafana (explication ci-dessous)
dependency "dns_ingress" {
  config_path = "../dns-ingress"
  
  mock_outputs = {
    acm_certificate_arn = "arn:aws:acm:eu-west-1:123456789012:certificate/mock-uuid"
    waf_web_acl_arn     = "arn:aws:wafv2:eu-west-1:123456789012:regional/webacl/mock-uuid"
  }
  mock_outputs_allowed_statuses_names = ["unapplied"]
}

inputs = {
  environment       = "nonprod"
  oidc_provider_url = dependency.eks.outputs.oidc_provider_url
  oidc_provider_arn = dependency.eks.outputs.oidc_provider_arn
  logs_bucket_name  = dependency.shared.outputs.bucket_logs_id
  kms_logs_key_arn  = dependency.shared.outputs.kms_logs_key_arn

  # Exposition de Grafana
  grafana_ingress_enabled = true
  grafana_domain_name     = "grafana.nonprod.rhorizon.xyz"
  acm_certificate_arn     = dependency.dns_ingress.outputs.acm_certificate_arn
  waf_web_acl_arn         = dependency.dns_ingress.outputs.waf_web_acl_arn
}
```

---

## 4. Commandes Utiles (CLI Redesign v0.60+)

Pour exécuter des commandes sur **une seule stack** :
*   Se positionner dans le dossier (ex: `cd live/nonprod/network`)
*   Lancer la commande : `terragrunt plan` ou `terragrunt apply` (ou explicitement `terragrunt run plan` / `terragrunt run apply`).

Pour exécuter des commandes sur **tout un environnement** :
*   Se positionner dans le dossier parent (ex: `cd live/nonprod`)
*   Lancer la commande :
    *   `terragrunt run --all validate` : valide toutes les syntaxes de manière orchestrée.
    *   `terragrunt run --all plan` : génère le plan de toutes les stacks dans le bon ordre en gérant les dépendances.
    *   `terragrunt run --all apply` : déploie toutes les stacks dans le bon ordre.
    *   `terragrunt run --all destroy` : détruit tout l'environnement de manière ordonnée.

*Note : L'ancienne syntaxe `terragrunt run-all <command>` ou taper par mégarde `terragrunt run all-<command>` provoquera une erreur d'exécution. Utilisez impérativement `run --all`.*
