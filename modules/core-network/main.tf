# Recuperation des zones de disponibilite dans la region courante
data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_region" "current" {}

locals {
  vpc_mask = tonumber(split("/", var.vpc_cidr)[1])
  newbits  = var.subnet_cidr_mask - local.vpc_mask
  az_names = slice(data.aws_availability_zones.available.names, 0, var.az_count)
}

# --- VPC ---
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name        = "${var.environment}-vpc"
    Environment = var.environment
    Project     = "RHZORION"
  }
}

# --- Subnets Tiers ---

# 1. Tier Public (Load Balancers & NAT Gateways)
resource "aws_subnet" "public" {
  count                   = var.az_count
  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(var.vpc_cidr, local.newbits, count.index)
  availability_zone       = local.az_names[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name                     = "${var.environment}-public-subnet-${count.index + 1}"
    Environment              = var.environment
    Project                  = "RHZORION"
    Type                     = "public"
    "kubernetes.io/role/elb" = "1"
  }
}

# 2. Tier Applicatif / Prive (Noeuds EKS)
resource "aws_subnet" "private" {
  count                   = var.az_count
  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(var.vpc_cidr, local.newbits, count.index + 10)
  availability_zone       = local.az_names[count.index]
  map_public_ip_on_launch = false

  tags = {
    Name                              = "${var.environment}-private-subnet-${count.index + 1}"
    Environment                       = var.environment
    Project                           = "RHZORION"
    Type                              = "private"
    "kubernetes.io/role/internal-elb" = "1"
  }
}

# 3. Tier Data / Isole (RDS PostgreSQL)
resource "aws_subnet" "data" {
  count                   = var.az_count
  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(var.vpc_cidr, local.newbits, count.index + 20)
  availability_zone       = local.az_names[count.index]
  map_public_ip_on_launch = false

  tags = {
    Name        = "${var.environment}-data-subnet-${count.index + 1}"
    Environment = var.environment
    Project     = "RHZORION"
    Type        = "data"
  }
}

# --- Internet Gateway ---
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name        = "${var.environment}-igw"
    Environment = var.environment
    Project     = "RHZORION"
  }
}

# --- NAT Gateways (Dynamiques en fonction de la strategie) ---
locals {
  nat_count = var.nat_strategy == "single" ? 1 : var.az_count
}

resource "aws_eip" "nat" {
  count  = local.nat_count
  domain = "vpc"

  tags = {
    Name        = "${var.environment}-nat-eip-${count.index + 1}"
    Environment = var.environment
    Project     = "RHZORION"
  }
}

resource "aws_nat_gateway" "nat" {
  count         = local.nat_count
  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id

  tags = {
    Name        = "${var.environment}-nat-gw-${count.index + 1}"
    Environment = var.environment
    Project     = "RHZORION"
  }

  depends_on = [aws_internet_gateway.igw]
}

# --- Tables de Routage ---

# Public RT
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name        = "${var.environment}-public-rt"
    Environment = var.environment
    Project     = "RHZORION"
  }
}

# Private RTs (une par AZ pour la haute disponibilite)
resource "aws_route_table" "private" {
  count  = var.az_count
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat[var.nat_strategy == "single" ? 0 : count.index].id
  }

  tags = {
    Name        = "${var.environment}-private-rt-${count.index + 1}"
    Environment = var.environment
    Project     = "RHZORION"
  }
}

# Data RT (Isolee, pas de route internet par defaut)
resource "aws_route_table" "data" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name        = "${var.environment}-data-rt"
    Environment = var.environment
    Project     = "RHZORION"
  }
}

# --- Associations des Tables de Routage ---

resource "aws_route_table_association" "public" {
  count          = var.az_count
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
  count          = var.az_count
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}

resource "aws_route_table_association" "data" {
  count          = var.az_count
  subnet_id      = aws_subnet.data[count.index].id
  route_table_id = aws_route_table.data.id
}

# --- Route 53 Zone Privee (PHZ) ---
resource "aws_route53_zone" "private" {
  count = var.enable_phz ? 1 : 0
  name  = var.private_domain_name

  vpc {
    vpc_id = aws_vpc.main.id
  }

  tags = {
    Name        = "${var.environment}-phz"
    Environment = var.environment
    Project     = "RHZORION"
  }
}

# --- VPC Flow Logs (CloudWatch) ---
resource "aws_cloudwatch_log_group" "flow_log" {
  name              = "/aws/vpc-flow-log/${var.environment}-vpc"
  retention_in_days = var.flow_logs_retention_days

  tags = {
    Environment = var.environment
    Project     = "RHZORION"
  }
}

resource "aws_iam_role" "flow_log" {
  name = "${var.environment}-vpc-flow-logs-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "vpc-flow-logs.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "flow_log" {
  name = "${var.environment}-vpc-flow-logs-policy"
  role = aws_iam_role.flow_log.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams"
        ]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}

resource "aws_flow_log" "main" {
  iam_role_arn    = aws_iam_role.flow_log.arn
  log_destination = aws_cloudwatch_log_group.flow_log.arn
  traffic_type    = "ALL"
  vpc_id          = aws_vpc.main.id

  tags = {
    Name        = "${var.environment}-vpc-flow-logs"
    Environment = var.environment
    Project     = "RHZORION"
  }
}

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
    Name        = "${var.environment}-vpc-endpoint-s3"
    Environment = var.environment
    Project     = "RHZORION"
  }
}

# Security Group pour les VPC Endpoints d'interface
resource "aws_security_group" "vpc_endpoints" {
  count       = var.enable_vpc_endpoints ? 1 : 0
  name        = "${var.environment}-vpc-endpoints-sg"
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
    Name        = "${var.environment}-vpc-endpoints-sg"
    Environment = var.environment
    Project     = "RHZORION"
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
    Name        = "${var.environment}-vpc-endpoint-${each.value}"
    Environment = var.environment
    Project     = "RHZORION"
  }
}

# --- Groupes de Securite de base (Tiers Applicatif) ---

# 1. Security Group pour l'ALB Public (Load Balancer)
resource "aws_security_group" "alb" {
  name        = "${var.environment}-sg-alb"
  description = "SG for Public ALB"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "Allow HTTP from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow HTTPS from anywhere"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.environment}-sg-alb"
    Environment = var.environment
    Project     = "RHZORION"
  }
}

# 2. Security Group pour EKS (Nodes & Pods)
resource "aws_security_group" "app" {
  name        = "${var.environment}-sg-app"
  description = "SG for EKS Nodes and Pods"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "Allow Ingress HTTP/HTTPS from ALB"
    from_port       = 8080
    to_port         = 8443
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  ingress {
    description = "Allow CoreDNS TCP"
    from_port   = 53
    to_port     = 53
    protocol    = "tcp"
    self        = true
  }

  ingress {
    description = "Allow CoreDNS UDP"
    from_port   = 53
    to_port     = 53
    protocol    = "udp"
    self        = true
  }

  egress {
    description = "Allow HTTPS Outbound (AWS API, endpoints)"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow DNS Outbound TCP"
    from_port   = 53
    to_port     = 53
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow DNS Outbound UDP"
    from_port   = 53
    to_port     = 53
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.environment}-sg-app"
    Environment = var.environment
    Project     = "RHZORION"
  }
}

# Rapprochement ALB -> EKS sans dependance circulaire
resource "aws_security_group_rule" "alb_egress_to_app" {
  type                     = "egress"
  from_port                = 8080
  to_port                  = 8443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.alb.id
  source_security_group_id = aws_security_group.app.id
  description              = "Allow outbound to app tier"
}

# 3. Security Group pour RDS PostgreSQL
resource "aws_security_group" "rds" {
  name        = "${var.environment}-sg-rds"
  description = "SG for RDS PostgreSQL"
  vpc_id      = aws_vpc.main.id

  egress {
    description = "Allow outbound inside VPC only"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.vpc_cidr]
  }

  tags = {
    Name        = "${var.environment}-sg-rds"
    Environment = var.environment
    Project     = "RHZORION"
  }
}

resource "aws_security_group_rule" "rds_ingress_from_eks" {
  type                     = "ingress"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  security_group_id        = aws_security_group.rds.id
  source_security_group_id = aws_security_group.app.id
  description              = "Allow Ingress PostgreSQL from EKS App only"
}

