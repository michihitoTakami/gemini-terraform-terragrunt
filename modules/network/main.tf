# 変数定義
variable "vpc_cidr_block" {
  type = string
  default = "10.0.0.0/16"
}

variable "private_subnet_cidr_block" {
  type = string
  default = "10.0.0.0/24"
}

variable "public_subnet_cidr_block" {
  type = string
  default = "10.0.1.0/24"
}

variable "app_name" {
  type = string
}

variable "env" {
  type = string
}

# VPCの作成
resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr_block

  tags = {
    Name = "${var.app_name}-vpc"
    Project = var.app_name
    Env = var.env
  }
}

# Private Subnetの作成
resource "aws_subnet" "private" {
  vpc_id     = aws_vpc.main.id
  cidr_block = var.private_subnet_cidr_block

  tags = {
    Name = "${var.app_name}-private-subnet"
    Project = var.app_name
    Env = var.env
  }
}

# Public Subnetの作成
resource "aws_subnet" "public" {
  vpc_id     = aws_vpc.main.id
  cidr_block = var.public_subnet_cidr_block

  tags = {
    Name = "${var.app_name}-public-subnet"
    Project = var.app_name
    Env = var.env
  }
}

# インターネットゲートウェイの作成
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.app_name}-igw"
    Project = var.app_name
    Env = var.env
  }
}

# ルートテーブルの作成
resource "aws_route_table" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.app_name}-main-route-table"
    Project = var.app_name
    Env = var.env
  }
}

# Public Subnetへのルート設定
resource "aws_route" "public_igw_route" {
  route_table_id = aws_route_table.main.id
  destination_cidr_block     = "0.0.0.0/0"
  gateway_id     = aws_internet_gateway.igw.id
}