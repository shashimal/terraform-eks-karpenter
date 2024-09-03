data "aws_eks_cluster_auth" "this" {
  name = module.eks.cluster_name
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

data "aws_iam_policy_document" "cluster_additional_policy_document" {
  statement {
    sid = "ECRPermission"
    effect = "Allow"
    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:BatchGetImage",
      "ecr:GetDownloadUrlForLayer",
      "ecr:GetAuthorizationToken"
    ]
    resources = ["*"]
  }
}