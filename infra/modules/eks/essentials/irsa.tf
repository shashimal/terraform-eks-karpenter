module "secret_manager_irsa_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~>5.15"

  role_name = "SecretManagerServiceRole"
  role_policy_arns = {
    policy = aws_iam_policy.secret_manger_access_policy.arn
  }

  oidc_providers = {
    ex = {
      provider_arn = var.oidc_provider_arn
      namespace_service_accounts = ["${var.namespace}:SecretManagerServiceAccount"]
    }
  }
}

resource "kubernetes_service_account" "secret_manager_sa" {
  metadata {
    name      = "secret-manager-sa"
    namespace = var.namespace
    annotations = {
      "eks.amazonaws.com/role-arn" = module.secret_manager_irsa_role.iam_role_arn
    }
  }
}