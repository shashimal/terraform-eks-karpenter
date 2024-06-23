module "vpc" {
  source = "../../modules/vpc"

  name               = local.app_name
  azs                = ["ap-southeast-1a", "ap-southeast-1b"]
  cidr               = "20.0.0.0/16"
  private_subnets    = ["20.0.0.0/19", "20.0.32.0/19"]
  public_subnets     = ["20.0.64.0/19", "20.0.96.0/19"]
  database_subnets   = ["20.0.128.0/19", "20.0.160.0/19"]
  enable_nat_gateway = true
  single_nat_gateway = true

  public_subnet_tags = {
    "kubernetes.io/role/elb" = "1"
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = "1"
  }
}

module "eks" {
  source = "../../modules/eks"

  cluster_name = local.app_name
  cluster_version = "1.29"

  cluster_endpoint_private_access = true
  cluster_endpoint_public_access = true
  enable_cluster_creator_admin_permissions = true

  vpc_id = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets
  control_plane_subnet_ids = module.vpc.intra_subnets

  eks_managed_node_groups = {
    karpenter = {
      instance_types = ["t3.medium"]
      min_size     = 2
      max_size     = 3
      desired_size = 2
    }
  }

  tags = {
    "karpenter.sh/discovery" = local.app_name
  }
}