locals {
  app_name = "student-management-sys"
  env      = "dev"
  common_tags = {
    Name = local.app_name
    env  = local.env
  }

  #VPC
  azs = ["ap-southeast-1a", "ap-southeast-1b"]
  cidr = "30.0.0.0/16"
  private_subnets = ["30.0.0.0/19", "30.0.32.0/19"]
  public_subnets = ["30.0.64.0/19", "30.0.96.0/19"]
  database_subnets = ["30.0.128.0/19", "30.0.160.0/19"]
}