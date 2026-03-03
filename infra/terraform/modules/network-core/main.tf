# network-core — Etap 1: locals, VPC, subnety (Krok 3 workbook)
# Etap 2 (IGW, EIP, NAT) i Etap 3 (route tables, associations) — dopisać w kolejnych krokach

locals {
  common_tags = merge(var.tags, {
    Project   = "OrderFlow-AWS-Lab"
    Env       = "dev"
    ManagedBy = "terraform"
    Module    = "network-core"
  })
}

# --- VPC ---

resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(local.common_tags, {
    Name = "${var.name_prefix}-vpc"
  })
}

# --- Subnety public ---

resource "aws_subnet" "public_a" {
  vpc_id                  = aws_vpc.this.id
  availability_zone       = var.azs[0]
  cidr_block              = var.public_subnet_cidrs[0]
  map_public_ip_on_launch = true

  tags = merge(local.common_tags, {
    Name = "${var.name_prefix}-public-a"
  })
}

resource "aws_subnet" "public_b" {
  vpc_id                  = aws_vpc.this.id
  availability_zone       = var.azs[1]
  cidr_block              = var.public_subnet_cidrs[1]
  map_public_ip_on_launch = true

  tags = merge(local.common_tags, {
    Name = "${var.name_prefix}-public-b"
  })
}

# --- Subnety private ---

resource "aws_subnet" "private_a" {
  vpc_id                  = aws_vpc.this.id
  availability_zone       = var.azs[0]
  cidr_block              = var.private_subnet_cidrs[0]
  map_public_ip_on_launch = false

  tags = merge(local.common_tags, {
    Name = "${var.name_prefix}-private-a"
  })
}

resource "aws_subnet" "private_b" {
  vpc_id                  = aws_vpc.this.id
  availability_zone       = var.azs[1]
  cidr_block              = var.private_subnet_cidrs[1]
  map_public_ip_on_launch = false

  tags = merge(local.common_tags, {
    Name = "${var.name_prefix}-private-b"
  })
}

# --- IGW, EIP, NAT (Etap 2) ---

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = merge(local.common_tags, {
    Name = "${var.name_prefix}-igw"
  })
}

resource "aws_eip" "nat" {
  count = var.enable_nat_gateway ? 1 : 0

  domain = "vpc"

  tags = merge(local.common_tags, {
    Name = "${var.name_prefix}-nat-eip"
  })
}

resource "aws_nat_gateway" "this" {
  count = var.enable_nat_gateway ? 1 : 0

  allocation_id = aws_eip.nat[0].id
  subnet_id     = aws_subnet.public_a.id

  tags = merge(local.common_tags, {
    Name = "${var.name_prefix}-nat"
  })
}

# --- Route tables i trasy (Etap 3) ---

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  tags = merge(local.common_tags, {
    Name = "${var.name_prefix}-public-rt"
  })
}

resource "aws_route" "public_internet" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this.id
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.this.id

  tags = merge(local.common_tags, {
    Name = "${var.name_prefix}-private-rt"
  })
}

resource "aws_route" "private_internet" {
  count = var.enable_nat_gateway ? 1 : 0

  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.this[0].id
}

resource "aws_route_table_association" "public_a" {
  subnet_id      = aws_subnet.public_a.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_b" {
  subnet_id      = aws_subnet.public_b.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private_a" {
  subnet_id      = aws_subnet.private_a.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private_b" {
  subnet_id      = aws_subnet.private_b.id
  route_table_id = aws_route_table.private.id
}
