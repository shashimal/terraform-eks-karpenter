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

data "aws_iam_policy_document" "pod_s3_access" {
  statement {
    sid    = "S3Access"
    effect = "Allow"

    actions = [
      "s3:*",
    ]

    resources = ["*"]
  }
}