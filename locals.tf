locals {
  app_metadata = {
    name = "eks-karpenter"
    env  = "dev"
  }

  cidr = "10.0.0.0/16"

  azs = ["ap-southeast-1a", "ap-southeast-1b", "ap-southeast-1c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  policy_arn_prefix = "arn:${data.aws_partition.current.partition}:iam::aws:policy"

  karpenter_nodeclasses = [
    {
      nodeclass_name = "default"
      karpenter_subnet_selector_maps = [
        {
          tags = {
            "kubernetes.io/role/internal-elb" = "1"
          }
        }
      ]
      karpenter_node_role = aws_iam_role.workers.name
      karpenter_security_group_selector_maps = [
        {
          "id" = module.eks.cluster_primary_security_group_id
        }
      ]
      karpenter_node_metadata_options = {
        httpEndpoint            = "enabled"
        httpProtocolIPv6        = "disabled"
        httpPutResponseHopLimit = 1
        httpTokens              = "required"
      }
      karpenter_ami_selector_maps = []
      karpenter_node_user_data = ""
      karpenter_node_tags_map = {
        "karpenter.sh/discovery" = module.eks.cluster_name,
        "eks:cluster-name"       = module.eks.cluster_name,
      }
      karpenter_ami_family = "Bottlerocket"
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
    },
  ]

  karpenter_nodepools = [
    {
      nodepool_name  = "default"
      nodeclass_name = "default"
      karpenter_nodepool_node_labels = {}
      karpenter_nodepool_annotations = {}
      karpenter_nodepool_node_taints = []
      karpenter_nodepool_startup_taints = []
      karpenter_requirements = [
        {
          key      = "karpenter.k8s.aws/instance-category"
          operator = "In"
          values = ["m"]
        }, {
          key      = "karpenter.k8s.aws/instance-cpu"
          operator = "In"
          values = ["2"]
        }, {
          key      = "karpenter.k8s.aws/instance-generation"
          operator = "In"
          values = ["1"]
        }, {
          key      = "karpenter.sh/capacity-type"
          operator = "In"
          values = ["on-demand"]
        }, {
          key      = "kubernetes.io/arch"
          operator = "In"
          values = ["amd64"]
        }, {
          key      = "kubernetes.io/os"
          operator = "In"
          values = ["linux"]
        }
      ]
      karpenter_nodepool_disruption = {
        consolidation_policy = "WhenUnderutilized" # WhenUnderutilized or WhenEmpty
        # consolidate_after    = "10m"               # Only used if consolidation_policy is WhenEmpty
        expire_after         = "168h" # 7d | 168h | 1w
      }
      karpenter_nodepool_disruption_budgets = [
        {
          nodes = "10%"
        }
      ]
      karpenter_nodepool_weight = 10
    },
    {
      nodepool_name  = "cost-optimized-spot-pool"
      nodeclass_name = "default"
      karpenter_nodepool_node_labels = {
        cost-optimized = "true"
      }
      karpenter_nodepool_annotations = {}
      karpenter_nodepool_node_taints = [
        {
          key    = "deployment"
          effect = "NoSchedule"
          value  = "cost-optimized-spot-pool"
        }
      ]
      karpenter_nodepool_startup_taints = []
      karpenter_requirements = [
        {
          key      = "karpenter.k8s.aws/instance-category"
          operator = "In"
          values = ["t"]
        }, {
          key      = "karpenter.k8s.aws/instance-cpu"
          operator = "In"
          values = ["1"]
        }, {
          key      = "karpenter.k8s.aws/instance-generation"
          operator = "In"
          values = ["2"]
        }, {
          key      = "karpenter.sh/capacity-type"
          operator = "In"
          values = ["on-demand"]
        }, {
          key      = "kubernetes.io/arch"
          operator = "In"
          values = ["amd64"]
        }, {
          key      = "kubernetes.io/os"
          operator = "In"
          values = ["linux"]
        }
      ]
      karpenter_nodepool_disruption = {
        consolidation_policy = "WhenUnderutilized" # WhenUnderutilized or WhenEmpty
        # consolidate_after    = "10m"               # Only used if consolidation_policy is WhenEmpty
        expire_after         = "168h" # 7d | 168h | 1w
      }
      karpenter_nodepool_disruption_budgets = [
        {
          nodes = "10%"
        }
      ]
      karpenter_nodepool_weight = 10
    }
  ]
}