module "rds_security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = ">= 5.0"

  name        = "${local.app_name}db-sg"
  description = "RDS security group"
  vpc_id      = module.vpc.vpc_id

  # ingress
  ingress_with_cidr_blocks = [
    {
      from_port   = 3306
      to_port     = 3306
      protocol    = "tcp"
      description = "RDS access from within VPC"
      cidr_blocks = local.cidr
    },
  ]
}