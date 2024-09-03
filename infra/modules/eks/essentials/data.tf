data "aws_iam_policy_document" "secret_manger_access_policy_document" {
  statement {
    sid = "SecretMangerPermission"
    effect = "Allow"
    actions = [
      "secretsmanager:GetSecretValue",
      "secretsmanager:DescribeSecret"
    ]
    resources = ["*"]
  }
}