variable "default_tags" {
    default = "k8s-env"
}

variable "vpc_cidr_block" {
  default = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "CIDR ranges for public subnets"
  type        = list(string)
  default     = ["10.0.4.0/24", "10.0.5.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDR ranges for private subnets"
  type        = list(string)
  default     = ["10.0.2.0/24", "10.0.3.0/24"]
}

variable "route_tables_names" {
  type    = list(string)
  default = ["public", "private-a", "private-b"]
}

variable "destination_cidr_block" {
  default = "0.0.0.0/0"
}