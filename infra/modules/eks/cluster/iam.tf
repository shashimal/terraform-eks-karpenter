resource "aws_iam_policy" "cluster_additional_permission_policy" {
  name = "eks-additional-permission-policies"
  policy = data.aws_iam_policy_document.cluster_additional_policy_document.json
}