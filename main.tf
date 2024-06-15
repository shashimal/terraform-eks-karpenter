module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~>20.13.1"

  cluster_name    = local.app_metadata.name
  cluster_version = "1.29"

  cluster_endpoint_public_access = true
  cluster_endpoint_private_access = true

  vpc_id = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets
  control_plane_subnet_ids = module.vpc.intra_subnets

  enable_cluster_creator_admin_permissions = true

  eks_managed_node_groups = {
    karpenter = {
      instance_types = ["t3.medium"]

      min_size     = 2
      max_size     = 3
      desired_size = 2
    }
  }

  tags = {
    "karpenter.sh/discovery" = local.app_metadata.name
  }
}

module "karpenter" {
  source = "./modules/karpenter"

  cluster_name = module.eks.cluster_name
  karpenter_namespace = "karpenter"
  oidc_provider_arn   = module.eks.oidc_provider_arn
  cluster_endpoint = module.eks.cluster_endpoint
  worker_iam_role_arn = aws_iam_role.workers.arn
  karpenter_nodeclasses = local.karpenter_nodeclasses
  karpenter_nodepools = local.karpenter_nodepools
}