locals {

  #EKS
  eks_managed_node_groups = {
    karpenter = {
      name           = "karpenter"
      max_size       = 3
      desired_size   = 2
      min_size       = 2
      instance_types = ["t3.medium"]

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

  enable_karpenter    = true
  enable_pod_identity = false
}

####################### Setup EKS Cluster ###################################
#############################################################################
module "eks" {
  source = "../../modules/eks/cluster"

  cluster_name    = local.app_name
  cluster_version = "1.32"

  vpc_id                   = module.vpc.vpc_id
  subnet_ids               = module.vpc.private_subnets
  control_plane_subnet_ids = module.vpc.private_subnets

  cluster_endpoint_public_access           = true
  enable_cluster_creator_admin_permissions = true

  bootstrap_self_managed_addons = true

  cluster_addons = {
    coredns                = {}
    eks-pod-identity-agent = {}
    kube-proxy             = {}
    vpc-cni                = {}
  }

  eks_managed_node_groups = local.eks_managed_node_groups
  node_security_group_tags = {
    "karpenter.sh/discovery" = local.app_name
  }

  tags = {
    Name = local.app_name
  }
}