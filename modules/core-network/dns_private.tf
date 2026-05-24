# --- Route 53 Zone Privee (PHZ) ---
resource "aws_route53_zone" "private" {
  count = var.enable_phz ? 1 : 0
  name  = var.private_domain_name

  vpc {
    vpc_id = aws_vpc.main.id
  }

  tags = {
    Name        = "${var.project_name}-${var.environment}-phz"
    Environment = var.environment
    Project     = upper(var.project_name)
  }
}
