variable "cluster_name" {
  description = "EKS cluster name"
  type = string
}

variable "app_name" {
  description = "Application name"
  type = string
  default = null
}

variable "oidc_provider_arn" {
  description = "OIDC provider arn"
  type = string
}

variable "namespace" {
  description = "Kubernetes namespace for application"
  type = string
  default = "default"
}