module "vpc" {
  source = "../../modules/vpc"

  name = local.app_name
  cidr = local.cidr
  azs  = local.azs

  private_subnets  = local.private_subnets
  public_subnets   = local.public_subnets
  database_subnets = local.database_subnets

  enable_nat_gateway     = true
  single_nat_gateway     = true
  one_nat_gateway_per_az = false

  create_database_subnet_group       = true
  create_database_subnet_route_table = true

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = "1"
  }

  public_subnet_tags = {
    "kubernetes.io/role/elb" = "1"
  }

  tags = {
    Name      = local.app_name
    Env       = local.env
    ManagedBy = "Terraform"
  }
}

module "eks_cluster" {
  source = "../../modules/eks/cluster"

  cluster_name    = local.app_name
  cluster_version = "1.30"

  vpc_id                   = module.vpc.vpc_id
  subnet_ids               = module.vpc.private_subnets
  control_plane_subnet_ids = module.vpc.intra_subnets

  cluster_endpoint_public_access = true

  eks_managed_node_groups = {
    karpenter = {
      instance_types = ["t3.medium"]
      min_size     = 2
      max_size     = 3
      desired_size = 2
    }
  }

  tags = {
    Name                     = local.app_name
    Env                      = local.env
    "karpenter.sh/discovery" = local.app_name
  }
}