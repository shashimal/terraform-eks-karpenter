module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~>20.22.0"

  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version

  cluster_endpoint_public_access  = var.cluster_endpoint_public_access
  cluster_endpoint_private_access = var.cluster_endpoint_private_access

  vpc_id                   = var.vpc_id
  subnet_ids               = var.subnet_ids
  control_plane_subnet_ids = var.control_plane_subnet_ids

  enable_cluster_creator_admin_permissions = var.enable_cluster_creator_admin_permissions
  access_entries = var.access_entries

  eks_managed_node_groups = var.eks_managed_node_groups
  iam_role_additional_policies = {
    additional = aws_iam_policy.cluster_additional_permission_policy.arn
  }

  tags = var.tags
}
