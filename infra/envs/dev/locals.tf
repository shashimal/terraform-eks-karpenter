locals {

  app_name = "sms"
  common_tags = {
    Name      = local.app_name
    Env       = "dev"
    Terraform = true
  }

}