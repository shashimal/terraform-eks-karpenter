# Install Secrets Store CSI Driver using Helm
resource "helm_release" "secrets_store_csi_driver" {
  name       = "secrets-store-csi-driver"
  repository = "https://kubernetes-sigs.github.io/secrets-store-csi-driver/charts"
  chart      = "secrets-store-csi-driver"
  namespace  = "kube-system"
  version    = "1.3.4"

  set {
    name  = "syncSecret.enabled"
    value = "true"
  }

  set {
    name  = "enableSecretRotation"
    value = "true"
  }

}

# Install AWS Provider for Secrets Store CSI Driver
resource "helm_release" "aws_secrets_manager_csi_provider" {
  name       = "secrets-store-csi-driver-provider-aws"
  repository = "https://aws.github.io/secrets-store-csi-driver-provider-aws"
  chart      = "secrets-store-csi-driver-provider-aws"
  namespace  = "kube-system"
  version    = "0.3.4"

  depends_on = [helm_release.secrets_store_csi_driver]
}

# Create IRSA for the CSI driver using AWS Terraform module
module "secrets_store_csi_driver_irsa" {
  source    = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version   = "~> 5.0"
  role_name = "secrets-store-csi-driver-role"

  role_policy_arns = {
    secrets_manager = "arn:aws:iam::aws:policy/SecretsManagerReadWrite"
  }

  oidc_providers = {
    main = {
      provider_arn               = var.oidc_provider_arn
      namespace_service_accounts = ["${var.namespace}:secrets-manager-sa"]
    }
  }
}

# Create service account with IAM role annotation
resource "kubernetes_service_account" "secrets_store_csi_driver" {
  metadata {
    name      = "secrets-manager-sa"
    namespace = var.namespace
    annotations = {
      "eks.amazonaws.com/role-arn" = module.secrets_store_csi_driver_irsa.iam_role_arn
    }
  }
  depends_on = [helm_release.secrets_store_csi_driver]
}