module "eks" {
  source = "../../../../modules/eks/cluster"

  cluster_name    = local.app_name
  cluster_version = "1.32"

  vpc_id                   = local.vpc_id
  subnet_ids               = local.private_subnet_ids
  control_plane_subnet_ids = local.private_subnet_ids

  cluster_endpoint_public_access           = true
  enable_cluster_creator_admin_permissions = true

  bootstrap_self_managed_addons = true

  cluster_addons = {
    coredns = {}
    eks-pod-identity-agent = {}
    kube-proxy = {}
    vpc-cni = {}
  }

  eks_managed_node_groups = local.eks_managed_node_groups
  node_security_group_tags = {
    "karpenter.sh/discovery" = local.app_name
  }

  tags = {
    Name = local.app_name
  }
}