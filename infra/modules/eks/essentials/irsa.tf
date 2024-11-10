terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.31.0"
    }
  }
}
module "secret_manager_irsa_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~>5.15"

  role_name = "${var.app_name}-secret-manager-service-role"
  role_policy_arns = {
    policy = aws_iam_policy.secret_manger_access_policy.arn
  }

  oidc_providers = {
    ex = {
      provider_arn = var.oidc_provider_arn
      namespace_service_accounts = ["${var.namespace}:secret-manager-sa"]
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

  depends_on = [kubernetes_namespace.namespace]
}

resource "kubernetes_service_account" "app_sa" {
  metadata {
    name      = "app-sa"
    namespace = var.namespace
    annotations = {}
  }

  depends_on = [kubernetes_namespace.namespace]
}

resource "kubernetes_namespace" "namespace" {
  metadata {
    annotations = {
      name = var.namespace
    }

    labels = {
      name = var.namespace
    }

    name = var.namespace
  }
}