variable "name" {
  type        = string
  description = "VPC name"
}

variable "cidr" {
  type        = string
  description = "VPC CIDR"
}

variable "azs" {
  type = list(string)
  description = "Availability zones"
}

variable "private_subnets" {
  type = list(string)
  description = "Private subnets"
}

variable "public_subnets" {
  type = list(string)
  description = "Public subnets"
}

variable "database_subnets" {
  type = list(string)
  description = "Database subnets"
}

variable "enable_nat_gateway" {
  type        = bool
  description = "Enable Nat Gateway"
}

variable "single_nat_gateway" {
  type        = bool
  description = "Single Nat Gateway "
}

variable "tags" {
  type = any
  description = "Tags"
  default = {}
}

variable "public_subnet_tags" {
  type = any
  description = "Public subnet tags"
  default = {}
}

variable "private_subnet_tags" {
  type = any
  description = "Private subnet tags"
  default = {}
}