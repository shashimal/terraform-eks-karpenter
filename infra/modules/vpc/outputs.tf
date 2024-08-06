output "vpc_id" {
  description = "VPC Id"
  value = module.vpc.vpc_id
}

output "vpc_cidr" {
  description = "VPC CIDR"
  value = module.vpc.vpc_cidr_block
}

output "private_subnets" {
  description = "Private subnet ids"
  value = module.vpc.private_subnets
}

output "public_subnets" {
  description = "Public subnet ids"
  value = module.vpc.public_subnets
}

output "vpc_owner_id" {
  description = "VPC owner id"
  value = module.vpc.vpc_owner_id
}

output "database_subnet_group" {
  description = "Database subnet group"
  value = module.vpc.database_subnet_group
}