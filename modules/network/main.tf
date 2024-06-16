# 変数の定義
variable "vpc_cidr_block" {
  type = string
}

variable "public_subnet_cidr_block" {
  type = string
}

variable "private_subnet_cidr_block" {
  type = string
}

variable "app_name" {
  type = string
}

variable "env" {
  type = string
}

# VPCの作成
resource "aws_vpc" "vpc" {
  cidr_block = var.vpc_cidr_block

  tags = {
    Name = "${var.app_name}-vpc"
    Project = var.app_name
    Env = var.env
  }
}

# インターネットゲートウェイの作成
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${var.app_name}-igw"
    Project = var.app_name
    Env = var.env
  }
}

# パブリックサブネットの作成
resource "aws_subnet" "public_subnet" {
  vpc_id = aws_vpc.vpc.id
  cidr_block = var.public_subnet_cidr_block
  availability_zone = "ap-northeast-1a"

  tags = {
    Name = "${var.app_name}-public-subnet"
    Project = var.app_name
    Env = var.env
  }
}

# プライベートサブネットの作成
resource "aws_subnet" "private_subnet" {
  vpc_id = aws_vpc.vpc.id
  cidr_block = var.private_subnet_cidr_block
  availability_zone = "ap-northeast-1b"

  tags = {
    Name = "${var.app_name}-private-subnet"
    Project = var.app_name
    Env = var.env
  }
}

# NATゲートウェイの作成
resource "aws_nat_gateway" "nat" {
  subnet_id = aws_subnet.public_subnet.id

  tags = {
    Name = "${var.app_name}-nat-gateway"
    Project = var.app_name
    Env = var.env
  }
}

# ルートテーブルの作成
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${var.app_name}-public-route-table"
    Project = var.app_name
    Env = var.env
  }
}

# インターネットへのルートの設定
resource "aws_route" "public_route" {
  route_table_id = aws_route_table.public_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.igw.id
}

# プライベートサブネット用のルートテーブルの作成
resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${var.app_name}-private-route-table"
    Project = var.app_name
    Env = var.env
  }
}

# NATゲートウェイへのルートの設定
resource "aws_route" "private_route" {
  route_table_id = aws_route_table.private_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.nat.id
}

# パブリックサブネットとルートテーブルの関連付け
resource "aws_route_table_association" "public_subnet_association" {
  subnet_id = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_route_table.id
}

# プライベートサブネットとルートテーブルの関連付け
resource "aws_route_table_association" "private_subnet_association" {
  subnet_id = aws_subnet.private_subnet.id
  route_table_id = aws_route_table.private_route_table.id
}