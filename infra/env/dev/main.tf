####################### Setup VPC ###################################
######################################################################
module "vpc" {
  source = "../../modules/network/vpc"

  name = local.app_name
  azs  = local.azs
  cidr = local.cidr

  private_subnets  = local.private_subnets
  public_subnets   = local.public_subnets
  database_subnets = local.database_subnets

  enable_nat_gateway = true
  single_nat_gateway = true

  public_subnet_tags = {
    Name                     = "public-subnet"
    "kubernetes.io/role/elb" = 1
  }

  private_subnet_tags = {
    Name                              = "app-subnet"
    "kubernetes.io/role/internal-elb" = 1
    "karpenter.sh/discovery"          = local.app_name
  }

  tags = local.common_tags
}

####################### Setup ECR Repositories #######################
######################################################################
module "ecr" {
  source = "../../modules/ecr"

  for_each = local.ecr_repositories

  repository_name                 = each.value.repository_name
  repository_image_tag_mutability = each.value.repository_image_tag_mutability
  repository_lifecycle_policy     = each.value.repository_lifecycle_policy
}

####################### Setup GitHub Action Role for App Deployment #######################
##########################################################################################
module "gha" {
  source = "../../modules/cicd"

  app_name    = local.app_name
  github_repo = local.github_repo
}