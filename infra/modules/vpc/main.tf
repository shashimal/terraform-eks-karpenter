module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~>5.8.1"

  name = var.name
  cidr = var.cidr

  azs             = var.azs
  private_subnets = var.private_subnets
  public_subnets  = var.public_subnets
  database_subnets = var.database_subnets
  create_database_subnet_group = true
  create_database_subnet_route_table = true

  enable_nat_gateway     = var.enable_nat_gateway
  single_nat_gateway     = var.single_nat_gateway
  one_nat_gateway_per_az = false

  enable_dns_hostnames = true
  enable_dns_support   = true

  public_subnet_tags = var.public_subnet_tags
  private_subnet_tags = var.private_subnet_tags
  tags = var.tags
}