output "vpc_id" {
  value = aws_vpc.main.id
  description = "VPC ID"
}

output "private_subnet_id" {
  value = aws_subnet.private.id
  description = "Private Subnet ID"
}

output "public_subnet_id" {
  value = aws_subnet.public.id
  description = "Public Subnet ID"
}

output "route_table_id" {
  value = aws_route_table.main.id
  description = "Route Table ID"
}