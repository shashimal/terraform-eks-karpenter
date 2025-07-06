####################### Setup VPC #######################
module "vpc" {
  source = "../../../../modules/network/vpc"

  name = local.app_name
  azs  = local.azs
  cidr = local.cidr

  private_subnets = local.private_subnets
  public_subnets = local.public_subnets
  database_subnets = local.database_subnets

  enable_nat_gateway = true
  single_nat_gateway = true

  public_subnet_tags = {
    Name = "public-subnet"
    "kubernetes.io/role/elb" = 1
  }

  private_subnet_tags = {
    Name = "app-subnet"
    "kubernetes.io/role/internal-elb" = 1
    "karpenter.sh/discovery"          = local.app_name
  }

  tags = local.common_tags
}