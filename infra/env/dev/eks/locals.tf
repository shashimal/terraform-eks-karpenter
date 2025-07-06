locals {
  app_name = "student-management-sys"

  #VPC
  vpc_id = data.aws_vpc.vpc.id
  azs = ["ap-southeast-1a", "ap-southeast-1b"]
  cidr = "20.0.0.0/16"
  private_subnet_ids = data.aws_subnets.private.ids
  public_subnet_ids = data.aws_subnets.public.ids

  #EKS
  eks_managed_node_groups = {
    karpenter  = {
      name         = "karpenter"
      max_size     = 3
      desired_size = 2
      min_size     = 2
      instance_types = ["t3.medium"]

      taints = {
        # This Taint aims to keep just EKS Addons and Karpenter running on this MNG
        # The pods that do not tolerate this taint should run on nodes created by Karpenter
        addons = {
          key    = "CriticalAddonsOnly"
          value  = "true"
          effect = "NO_SCHEDULE"
        },
      }
    }
  }

  enable_karpenter = true
  enable_pod_identity = false
}