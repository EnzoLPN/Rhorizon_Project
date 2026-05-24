# --- VPC Endpoints (PrivateLink) ---

# Endpoint Gateway pour S3 (gratuit et performant)
resource "aws_vpc_endpoint" "s3" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.${data.aws_region.current.name}.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = concat(
    [aws_route_table.public.id],
    aws_route_table.private[*].id,
    [aws_route_table.data.id]
  )

  tags = {
    Name        = "${var.project_name}-${var.environment}-vpc-endpoint-s3"
    Environment = var.environment
    Project     = upper(var.project_name)
  }
}

# Security Group pour les VPC Endpoints d'interface
resource "aws_security_group" "vpc_endpoints" {
  count       = var.enable_vpc_endpoints ? 1 : 0
  name        = "${var.project_name}-${var.environment}-vpc-endpoints-sg"
  description = "SG for VPC Interface Endpoints"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "Allow HTTPS from VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.project_name}-${var.environment}-vpc-endpoints-sg"
    Environment = var.environment
    Project     = upper(var.project_name)
  }
}

# Endpoints d'Interface (pour KMS, Secrets Manager, ECR, CloudWatch Logs, STS)
resource "aws_vpc_endpoint" "interface" {
  for_each            = var.enable_vpc_endpoints ? toset(var.vpc_endpoints) : []
  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.${data.aws_region.current.name}.${each.value}"
  vpc_endpoint_type   = "Interface"
  security_group_ids  = [aws_security_group.vpc_endpoints[0].id]
  subnet_ids          = aws_subnet.private[*].id
  private_dns_enabled = true

  tags = {
    Name        = "${var.project_name}-${var.environment}-vpc-endpoint-${each.value}"
    Environment = var.environment
    Project     = upper(var.project_name)
  }
}
