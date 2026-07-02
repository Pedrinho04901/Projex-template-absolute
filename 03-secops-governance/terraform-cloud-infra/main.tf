resource "aws_vpc" "fintech_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name        = "vpc-${var.environment}"
    Environment = var.environment
  }
}

resource "aws_subnet" "private_subnet_a" {
  vpc_id            = aws_vpc.fintech_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "${var.aws_region}a"

  tags = {
    Name        = "subnet-private-${var.environment}-a"
    "kubernetes.io/role/internal-elb" = "1"
  }
}

resource "aws_eks_cluster" "eks_core" {
  name     = var.cluster_name
  role_arn = "arn:aws:iam::123456789012:role/ProjexEKSClusterRole"

  vpc_config {
    subnet_ids = [aws_subnet.private_subnet_a.id]
    endpoint_private_access = true
    endpoint_public_access  = false
  }
}
