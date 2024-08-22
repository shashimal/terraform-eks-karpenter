## Networking

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
    Name                     = local.app_name
    Env                      = local.env
    ManagedBy                = "Terraform"
    "karpenter.sh/discovery" = local.app_name
  }
}

## EKS cluster
module "eks_cluster" {
  source = "../../modules/eks/cluster"

  cluster_name    = local.app_name
  cluster_version = "1.29"

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

      taints = {
        # This Taint aims to keep just EKS Addons and Karpenter running on this MNG
        # The pods that do not tolerate this taint should run on nodes created by Karpenter
        addons = {
          key    = "CriticalAddonsOnly"
          value  = "true"
          effect = "NO_SCHEDULE"
        },
      }
    }
  }

tags = {
  Name                     = local.app_name
  Env                      = local.env
  "karpenter.sh/discovery" = local.app_name
}
}

## Enable Karpenter for the EKS cluster
module "karpenter" {
source = "../../modules/eks/karpenter"

cluster_name = module.eks_cluster.cluster_name
karpenter_namespace = "karpenter"
oidc_provider_arn = module.eks_cluster.oidc_provider_arn
cluster_endpoint = module.eks_cluster.cluster_endpoint
worker_iam_role_arn = aws_iam_role.workers.arn
karpenter_nodeclasses = local.karpenter_nodeclasses
karpenter_nodepools = local.karpenter_nodepools
}