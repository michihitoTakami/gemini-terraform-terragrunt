variable "vpc_id" {
  type = string
  description = "VPC ID"
}

variable "web_app_port" {
  type = number
  description = "WEBアプリのポート番号"
  default = 80
}

resource "aws_security_group" "lb_sg" {
  name        = "lb-sg"
  vpc_id     = var.vpc_id

  ingress {
    from_port = var.web_app_port
    to_port   = var.web_app_port
    protocol = "tcp"

    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 443
    to_port   = 443
    protocol = "tcp"

    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port   = 0
    protocol = "-1"

    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "rds_sg" {
  name        = "rds-sg"
  vpc_id     = var.vpc_id

  ingress {
    from_port = 3306
    to_port   = 3306
    protocol = "tcp"

    security_groups = [aws_security_group.ecs_app_sg.id]
  }

  egress {
    from_port = 0
    to_port   = 0
    protocol = "-1"

    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "ecs_app_sg" {
  name        = "ecs-app-sg"
  vpc_id     = var.vpc_id

  ingress {
    from_port = var.web_app_port
    to_port   = var.web_app_port
    protocol = "tcp"

    security_groups = [aws_security_group.lb_sg.id]
  }

  egress {
    from_port = 0
    to_port   = 0
    protocol = "-1"

    cidr_blocks = ["0.0.0.0/0"]
  }
}