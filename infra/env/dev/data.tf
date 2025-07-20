
data "aws_caller_identity" "current" {}

data "aws_partition" "current" {}
################################ EKS ################################
#####################################################################
data "aws_eks_cluster_auth" "this" {
  name = module.eks.cluster_name
}

################################ IAM ################################
#####################################################################
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