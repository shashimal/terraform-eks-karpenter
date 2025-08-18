variable "repository_name" {
  description = "Repository name"
  type = string
}

variable "repository_image_tag_mutability" {
  description = "Repository image tag mutability"
  type = string
  default = "IMMUTABLE"
}

variable "repository_lifecycle_policy" {
  description = "Repository lifecycle policy"
  type = any
  default = {}
}