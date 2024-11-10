resource "aws_iam_policy" "secret_manger_access_policy" {
  name   = "${var.app_name}-secret-manager-access-policy"
  policy = data.aws_iam_policy_document.secret_manger_access_policy_document.json
}

resource "aws_iam_policy" "pod_s3_access" {
  name_prefix = "s3-access"
  path        = "/"
  description = "S3 access for service accounts"

  policy = data.aws_iam_policy_document.pod_s3_access.json
}
