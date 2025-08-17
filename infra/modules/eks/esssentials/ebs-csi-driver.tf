# Step 1: EBS CSI Driver IAM Role and Installation
# Required for persistent volumes in StatefulSet
module "ebs_csi_driver_irsa" {
  source = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "5.6"

  role_name = "${var.cluster_name}-ebs-csi-driver-role"

  attach_ebs_csi_policy = true

  oidc_providers = {
    main = {
      provider_arn = var.oidc_provider_arn
      namespace_service_accounts = [
        "kube-system:ebs-csi-controller-sa",
        "kube-system:ebs-csi-node-sa"
      ]
    }
  }
}

resource "helm_release" "ebs_csi_driver" {
  name       = "aws-ebs-csi-driver"
  repository = "https://kubernetes-sigs.github.io/aws-ebs-csi-driver"
  chart      = "aws-ebs-csi-driver"
  namespace  = "kube-system"
  version    = "2.25.0"

  set {
    name  = "controller.serviceAccount.create"
    value = "true"
  }

  set {
    name  = "controller.serviceAccount.name"
    value = "ebs-csi-controller-sa"
  }

  set {
    name  = "controller.serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = module.ebs_csi_driver_irsa.iam_role_arn
  }

  set {
    name  = "node.serviceAccount.create"
    value = "true"
  }

  set {
    name  = "node.serviceAccount.name"
    value = "ebs-csi-node-sa"
  }

  set {
    name  = "node.serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = module.ebs_csi_driver_irsa.iam_role_arn
  }

  # Enable volume snapshots
  set {
    name  = "controller.volumeModificationFeature.enabled"
    value = "true"
  }

  depends_on = [
    module.ebs_csi_driver_irsa
  ]
}

