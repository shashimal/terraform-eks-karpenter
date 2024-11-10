module "pod_identity_for_drupal" {
  source  = "terraform-aws-modules/eks-pod-identity/aws"
  version = "~> 1.6.1"

  name = "${var.app_name}-pod-identity"

  additional_policy_arns = {
    s3_access  = aws_iam_policy.pod_s3_access.arn
  }

  associations = {
    app = {
      cluster_name    = var.cluster_name
      namespace       = var.namespace
      service_account = "app-sa"
    }
  }
}