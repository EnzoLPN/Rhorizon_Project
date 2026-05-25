terraform {
  required_providers {
    aws = {
      source                = "hashicorp/aws"
      configuration_aliases = [aws.shared]
    }
  }
}

# --- Zone Route 53 Publique ---
resource "aws_route53_zone" "public" {
  count = var.create_public_zone ? 1 : 0
  name  = var.domain_name

  tags = {
    Name        = "${var.environment}-public-zone"
    Environment = var.environment
    Project     = upper(var.project_name)
  }
}

data "aws_route53_zone" "existing" {
  count = var.create_public_zone ? 0 : 1
  name  = var.domain_name
}

# --- Delegation Route53 automatique dans la zone parente (ex: compte shared) ---
variable "parent_zone_name" {
  type        = string
  description = "Nom de la zone DNS parente (ex: rhorizon.xyz) pour la délégation"
  default     = ""
}

data "aws_route53_zone" "parent" {
  count    = var.parent_zone_name != "" ? 1 : 0
  provider = aws.shared
  name     = var.parent_zone_name
}

resource "aws_route53_record" "delegation" {
  count    = var.parent_zone_name != "" && var.create_public_zone ? 1 : 0
  provider = aws.shared
  zone_id  = data.aws_route53_zone.parent[0].zone_id
  name     = var.domain_name
  type     = "NS"
  ttl      = 300
  records  = aws_route53_zone.public[0].name_servers
}
