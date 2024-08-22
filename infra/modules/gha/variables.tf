variable "app_name" {
  description = "Application name"
  type = string
}

variable "create_github_oidc_provider" {
  description = "Checks whether new github oidc provider needs to be created or not."
  type        = bool
  default     = false
}

variable "github_repo" {
  description = "Name of the Github Backend end Repo"
  type        = string
  default     = "shashimal/terraform-eks"
}