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
