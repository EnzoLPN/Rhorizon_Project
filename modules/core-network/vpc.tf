# --- VPC ---
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name        = "${var.project_name}-${var.environment}-vpc"
    Environment = var.environment
    Project     = upper(var.project_name)
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
    Name                     = "${var.project_name}-${var.environment}-public-subnet-${count.index + 1}"
    Environment              = var.environment
    Project     = upper(var.project_name)
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
    Name                              = "${var.project_name}-${var.environment}-private-subnet-${count.index + 1}"
    Environment                       = var.environment
    Project     = upper(var.project_name)
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
    Name        = "${var.project_name}-${var.environment}-data-subnet-${count.index + 1}"
    Environment = var.environment
    Project     = upper(var.project_name)
    Type        = "data"
  }
}

# --- Internet Gateway ---
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name        = "${var.project_name}-${var.environment}-igw"
    Environment = var.environment
    Project     = upper(var.project_name)
  }
}

# --- NAT Gateways ---
resource "aws_eip" "nat" {
  count  = local.nat_count
  domain = "vpc"

  tags = {
    Name        = "${var.project_name}-${var.environment}-nat-eip-${count.index + 1}"
    Environment = var.environment
    Project     = upper(var.project_name)
  }
}

resource "aws_nat_gateway" "nat" {
  count         = local.nat_count
  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id

  tags = {
    Name        = "${var.project_name}-${var.environment}-nat-gw-${count.index + 1}"
    Environment = var.environment
    Project     = upper(var.project_name)
  }

  depends_on = [aws_internet_gateway.igw]
}
