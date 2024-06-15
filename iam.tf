# Workers IAM Role
resource "aws_iam_role" "workers" {
  name        = "${local.app_metadata.name}-workers"
  description = "IAM Role for the workers in EKS Cluster named ${local.app_metadata.name}"

  assume_role_policy    = data.aws_iam_policy_document.ec2_assume_role_policy.json
  #permissions_boundary  = var.workers_iam_boundary
  force_detach_policies = true
}

resource "aws_iam_role_policy_attachment" "workers" {
  for_each = setunion(toset([
    "${local.policy_arn_prefix}/AmazonEKSWorkerNodePolicy",
    "${local.policy_arn_prefix}/AmazonEC2ContainerRegistryReadOnly",
    "${local.policy_arn_prefix}/AmazonSSMManagedInstanceCore",
    "${local.policy_arn_prefix}/AmazonEKS_CNI_Policy",
  ]), [])

  policy_arn = each.value
  role       = aws_iam_role.workers.name
}