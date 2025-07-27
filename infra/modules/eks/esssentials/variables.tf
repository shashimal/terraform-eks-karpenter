variable "oidc_provider_arn" {
  description = "OIDC provider arn"
  type        = string
}

variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
}

variable "vpc_id" {
  description = "VPC Id"
  type        = string
}
