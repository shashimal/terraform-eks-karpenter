module "ecr" {
  source  = "terraform-aws-modules/ecr/aws"
  version = "~>2.4"

  repository_name                 = var.repository_name
  repository_image_scan_on_push   = false
  repository_image_tag_mutability = var.repository_image_tag_mutability

  create_lifecycle_policy     = true
  repository_lifecycle_policy = var.repository_lifecycle_policy

  repository_force_delete = true
  repository_read_write_access_arns = [data.aws_caller_identity.current.account_id]
}