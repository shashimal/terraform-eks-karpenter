data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

data "aws_iam_openid_connect_provider" "gha" {
  url = "https://token.actions.githubusercontent.com"
}

data "aws_iam_policy_document" "ecr" {
  statement {
    actions = [
      "ecr:BatchGetImage",
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetRepositoryPolicy",
      "ecr:DescribeRepositories",
      "ecr:DescribeImages",
      "ecr:InitiateLayerUpload",
      "ecr:UploadLayerPart",
      "ecr:CompleteLayerUpload",
      "ecr:PutImage",
    ]
    resources = ["*"]
  }
}