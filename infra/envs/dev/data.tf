data "aws_eks_cluster_auth" "this" {
  name = module.eks_cluster.cluster_name
}

data "aws_partition" "current" {
}

data "aws_iam_policy_document" "ec2_assume_role_policy" {
  statement {
    sid     = "EKSNodeAssumeRole"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.${data.aws_partition.current.dns_suffix}"]
    }
  }
}

data "aws_iam_roles" "sso_admin_roles" {
  name_regex  = "AWSReservedSSO_AWSAdministratorAccess_.*"
  path_prefix = "/aws-reserved/sso.amazonaws.com/"
}