module "gha" {
  source  = "philips-labs/github-oidc/aws"
  version = "~> 0.8.0"

  openid_connect_provider_arn = data.aws_iam_openid_connect_provider.oidc.arn
  repo = var.github_repo
  role_name = "${var.app_name}-gha-role"
  default_conditions          = ["allow_all"]
  role_policy_arns            = [aws_iam_policy.ecr_permission_policy.arn]
}

resource "aws_iam_policy" "ecr_permission_policy" {
  name = "${var.app_name}-gha-permission"
  policy = data.aws_iam_policy_document.ecr.json
}