# 変数定義
variable "vpc_cidr_block" {
  type = "string"
  default = "10.0.0.0/16"
}

variable "private_subnet_cidr_block" {
  type = "string"
  default = "10.0.1.0/24"
}

variable "public_subnet_cidr_block" {
  type = "string"
  default = "10.0.2.0/24"
}

variable "app_name" {
  type = "string"
}

variable "env" {
  type = "string"
}

# VPCリソース
resource "aws_vpc" "vpc" {
  cidr_block = var.vpc_cidr_block

  tags = {
    Name  = var.app_name
    Project = var.app_name
    Env   = var.env
  }
}

# プライベートサブネットリソース
resource "aws_subnet" "private_subnet" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = var.private_subnet_cidr_block

  tags = {
    Name  = var.app_name + "-private-subnet"
    Project = var.app_name
    Env   = var.env
  }
}

# パブリックサブネットリソース
resource "aws_subnet" "public_subnet" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = var.public_subnet_cidr_block

  tags = {
    Name  = var.app_name + "-public-subnet"
    Project = var.app_name
    Env   = var.env
  }
}

# インターネットゲートウェイリソース
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name  = var.app_name + "-internet-gateway"
    Project = var.app_name
    Env   = var.env
  }
}

# ルートテーブルリソース
resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name  = var.app_name + "-private-route-table"
    Project = var.app_name
    Env   = var.env
  }
}

# S3へのVPCエンドポイント
resource "aws_vpc_endpoint" "s3_endpoint" {
  vpc_id          = aws_vpc.vpc.id
  service_name    = "com.amazonaws.ap-northeast-1.s3"
  vpc_endpoint_type = "Gateway"

  tags = {
    Name  = var.app_name + "-s3-endpoint"
    Project = var.app_name
    Env   = var.env
  }
}

# ECRへのVPCエンドポイント
resource "aws_vpc_endpoint" "ecr_endpoint" {
  vpc_id          = aws_vpc.vpc.id
  service_name    = "com.amazonaws.ap-northeast-1.ecr.dkr"
  subnet_ids     = [aws_subnet.private_subnet.id]
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true

  tags = {
    Name  = var.app_name + "-ecr-endpoint"
    Project = var.app_name
    Env   = var.env
  }
}

# ECR APIへのVPCエンドポイント
resource "aws_vpc_endpoint" "ecr_api_endpoint" {
  vpc_id          = aws_vpc.vpc.id
  service_name    = "com.amazonaws.ap-northeast-1.ecr.api"
  subnet_ids     = [aws_subnet.private_subnet.id]
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true

  tags = {
    Name  = var.app_name + "-ecr-api-endpoint"
    Project = var.app_name
    Env   = var.env
  }
}

# CloudWatch LogsへのVPCエンドポイント
resource "aws_vpc_endpoint" "logs_endpoint" {
  vpc_id          = aws_vpc.vpc.id
  service_name    = "com.amazonaws.ap-northeast-1.logs"
  subnet_ids     = [aws_subnet.private_subnet.id]
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true

  tags = {
    Name  = var.app_name + "-logs-endpoint"
    Project = var.app_name
    Env   = var.env
  }
}

# Systems ManagerへのVPCエンドポイント
resource "aws_vpc_endpoint" "ssm_endpoint" {
  vpc_id          = aws_vpc.vpc.id
  service_name    = "com.amazonaws.ap-northeast-1.ssm"
  subnet_ids     = [aws_subnet.private_subnet.id]
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true

  tags = {
    Name  = var.app_name + "-ssm-endpoint"
    Project = var.app_name
    Env   = var.env
  }
}

# インターネットゲートウェイへのルート設定
resource "aws_route" "public_route" {
  route_table_id = aws_route_table.public_route_table.id
  destination     = "0.0.0.0/0"
  gateway_id     = aws_internet_gateway.igw.id

  tags = {
    Name  = var.app_name + "-public-route"
    Project = var.app_name
    Env   = var.env
  }
}

# ネットワークACLリソース
resource "aws_network_acl" "nacl" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name  = var.app_name + "-network-acl"
    Project = var.app_name
    Env   = var.env
  }
}

# インバウンドデフォルトルール
resource "aws_network_acl_rule" "inbound_default_allow_all" {
  network_acl_id = aws_network_acl.nacl.id
  rule_action    = "allow"
  protocol       = "-1"
  source_cidr_block = "0.0.0.0/0"

  tags = {
    Name  = var.app_name + "-inbound-default-allow-all"
    Project = var.app_name
    Env   = var.env
  }
}

# アウトバウンドデフォルトルール
resource "aws_network_acl_rule" "outbound_default_allow_all" {
  network_acl_id = aws_network_acl.nacl.id
  rule_action    = "allow"
  protocol       = "-1"
  source_cidr_block = "0.0.0.0/0"

  tags = {
    Name  = var.app_name + "-outbound-default-allow-all"
    Project = var.app_name
    Env   = var.env
  }
}

# サブネットにネットワークACLを関連付け
resource "aws_subnet_association" "private_subnet_nacl_association" {
  subnet_id = aws_subnet.private_subnet.id
  network_acl_id = aws_network_acl.nacl.id

  tags = {
    Name  = var.app_name + "-private-subnet-nacl-association"
    Project = var.app_name
    Env   = var.env
  }
}

resource "aws_subnet_association" "public_subnet_nacl_association" {
  subnet_id = aws_subnet.public_subnet.id
  network_acl_id = aws_network_acl.nacl.id

  tags = {
    Name  = var.app_name + "-public-subnet-nacl-association"
    Project = var.app_name
    Env   = var.env
  }
}
