locals {
  app_name = "student-management-system"

  env = "dev"

  sms_duleendra_zone="Z025694321K6R42BEU4O"

  common_tags = {
    Name = local.app_name
    env  = local.env
  }

  github_repo = "shashimal/eks-app"

  #VPC
  azs              = ["ap-southeast-1a", "ap-southeast-1b"]
  cidr             = "40.0.0.0/16"
  private_subnets  = ["40.0.0.0/19", "40.0.32.0/19"]
  public_subnets   = ["40.0.64.0/19", "40.0.96.0/19"]
  database_subnets = ["40.0.128.0/19", "40.0.160.0/19"]

  #ECR
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

  ecr_repositories = {

    frontend = {
      repository_name                 = "frontend"
      repository_image_tag_mutability = "MUTABLE"
      repository_lifecycle_policy     = local.repository_lifecycle_policy
    }

    student-service = {
      repository_name                 = "student-service"
      repository_image_tag_mutability = "MUTABLE"
      repository_lifecycle_policy     = local.repository_lifecycle_policy
    }

    course-service = {
      repository_name                 = "course-service"
      repository_image_tag_mutability = "MUTABLE"
      repository_lifecycle_policy     = local.repository_lifecycle_policy
    }

    auth-service = {
      repository_name                 = "auth-service"
      repository_image_tag_mutability = "MUTABLE"
      repository_lifecycle_policy     = local.repository_lifecycle_policy
    }
  }
}