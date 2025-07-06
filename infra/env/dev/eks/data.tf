data "aws_caller_identity" "current" {}

data "aws_partition" "current" {}

################################ VPC ################################
#####################################################################
data "aws_vpc" "vpc" {
  filter {
    name   = "tag:Name"
    values = [local.app_name]
  }
}

data "aws_subnets" "private" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.vpc.id]
  }

  tags = {
    Name = "app-subnet"
  }
}

data "aws_subnets" "public" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.vpc.id]
  }

  tags = {
    Name = "public-subnet"
  }
}

data "aws_subnet" "private" {
  for_each = toset(data.aws_subnets.private.ids)
  id       = each.value
}

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
