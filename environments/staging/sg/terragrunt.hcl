include {
  path = find_in_parent_folders()
}

terraform {
  source   = "../../../modules/sg"
}

dependency "vpc" {
  config_path = "../network"
}

locals {
  vars = read_terragrunt_config(find_in_parent_folders()).locals
}

inputs =  {
  vpc_id = dependency.vpc.outputs.vpc_id
  web_app_port = 3000
}