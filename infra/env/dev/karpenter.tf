locals {
  karpenter_nodeclasses = [
    {
      nodeclass_name = "default"
      karpenter_subnet_selector_maps = [
        {
          tags = {
            "karpenter.sh/discovery" = local.app_name
          }
        }
      ]
      karpenter_node_role = aws_iam_role.workers.name
      karpenter_security_group_selector_maps = [
        {
          tags = {
            "karpenter.sh/discovery" = local.app_name
          }
        },
        {
          id = module.alb_sg.security_group_id

        }
        # {
        #   id = module.rds_security_group.security_group_id
        # }

      ]
      karpenter_ami_selector_maps = [
        {
          "alias" = "bottlerocket@latest"
        }
      ]
      karpenter_node_user_data = ""
      karpenter_node_tags_map = {
        "karpenter.sh/discovery" = module.eks.cluster_name,
        "eks:cluster-name"       = module.eks.cluster_name,
      }
      karpenter_block_device_mapping = [
        {
          #karpenter_root_volume_size
          "deviceName" = "/dev/xvda"
          "ebs" = {
            "encrypted"           = true
            "volumeSize"          = "5Gi"
            "volumeType"          = "gp3"
            "deleteOnTermination" = true
          }
          }, {
          #karpenter_ephemeral_volume_size
          "deviceName" = "/dev/xvdb",
          "ebs" = {
            "encrypted"           = true
            "volumeSize"          = "50Gi"
            "volumeType"          = "gp3"
            "deleteOnTermination" = true
          }
        }
      ]
      karpenter_node_metadata_options = {
        httpEndpoint            = "enabled"
        httpProtocolIPv6        = "disabled"
        httpPutResponseHopLimit = 1
        httpTokens              = "required"
      }
      karpenter_node_kubelet = {
        clusterDNS = []
      }
    }
  ]

  karpenter_nodepools = [
    {
      nodepool_name                     = "default"
      nodeclass_name                    = "default"
      karpenter_nodepool_node_labels    = {}
      karpenter_nodepool_annotations    = {}
      karpenter_nodepool_node_taints    = []
      karpenter_nodepool_startup_taints = []
      karpenter_requirements = [
        {
          key      = "karpenter.k8s.aws/instance-category"
          operator = "In"
          values   = ["t"]
          }, {
          key      = "karpenter.k8s.aws/instance-cpu"
          operator = "In"
          values   = ["2"]
          }, {
          key      = "karpenter.k8s.aws/instance-memory"
          operator = "In"
          values   = ["8192"]
          }, {
          key      = "karpenter.k8s.aws/instance-generation"
          operator = "Gt"
          values   = ["2"]
          }, {
          key      = "karpenter.sh/capacity-type"
          operator = "In"
          values   = ["on-demand"]
          }, {
          key      = "kubernetes.io/arch"
          operator = "In"
          values   = ["amd64"]
          }, {
          key      = "kubernetes.io/os"
          operator = "In"
          values   = ["linux"]
        }
      ]
      karpenter_nodepool_disruption = {
        consolidation_policy = "WhenEmptyOrUnderutilized" # WhenEmpty or WhenEmptyOrUnderutilized
        consolidate_after    = "20s"
        expire_after         = "168h" # 7d | 168h | 1w
      }
      karpenter_nodepool_disruption_budgets = [{
        nodes = "10%"
      }]
      karpenter_nodepool_weight = 10
    }
  ]
}

#Setup Karpenter
module "karpenter" {
  source = "../../modules/eks/karpenter"

  count = local.enable_karpenter ? 1 : 0

  cluster_name      = module.eks.cluster_name
  cluster_endpoint  = module.eks.cluster_endpoint
  oidc_provider_arn = module.eks.oidc_provider_arn

  enable_irsa         = false
  enable_pod_identity = true

  karpenter_namespace         = "kube-system"
  karpenter_chart_name        = "karpenter"
  karpenter_crd_chart_version = "1.3.3"

  worker_iam_role_arn   = aws_iam_role.workers.arn
  karpenter_nodeclasses = local.karpenter_nodeclasses
  karpenter_nodepools   = local.karpenter_nodepools

  depends_on = [module.eks]
}
