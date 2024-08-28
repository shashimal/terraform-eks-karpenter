module "ecr" {
  source  = "terraform-aws-modules/ecr/aws"
  version = "~>2.2.1"

  for_each = var.repository_map

  repository_name = each.value.name

  create_lifecycle_policy           = true
  repository_lifecycle_policy = jsonencode({
    rules = [
      {
        rulePriority = 1,
        description  = "Keep last 30 images",
        selection = {
          tagStatus     = "tagged",
          tagPrefixList = ["v"],
          countType     = "imageCountMoreThan",
          countNumber   = 30
        },
        action = {
          type = "expire"
        }
      }
    ]
  })

  repository_image_tag_mutability = each.value.repository_image_tag_mutability
  repository_force_delete = true

}