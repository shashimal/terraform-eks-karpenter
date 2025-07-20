variable "app_name" {
  description = "Application name"
  type        = string
}

variable "github_repo" {
  description = "Name of the Github Backend end Repo"
  type        = string
  default     = "shashimal/terraform-eks"
}