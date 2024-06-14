include {
  path = find_in_parent_folders()
}

terraform {
  source   = "../../../modules/network"
}

locals {
  vars = read_terragrunt_config(find_in_parent_folders()).locals
}

inputs =  {
  vpc_cidr_block = "10.102.0.0/16"
  private_subnet_cidr_block = "10.102.1.0/24"
  public_subnet_cidr_block= "10.102.2.0/24"
}