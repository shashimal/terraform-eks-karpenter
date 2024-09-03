resource "aws_iam_policy" "secret_manger_access_policy" {
  name   = "SecretManagerAccessPolicy"
  policy = data.aws_iam_policy_document.secret_manger_access_policy_document.json
}