variable "default_tags" {
  type = map(string)
  default = {
    "env" = "kinzh"
  }
  description = "kinzh variables decsription"
}

variable "public_subnet_count" {
  type        = number
  description = "public subnet count description"
  default     = 2
}

variable "private_subnet_count" {
  type = number
  description = "public subnet count description"
  default = 4
}

variable "vpc_cidr" {
  type = string
  default = "10.0.0.0/16"
  description = "Main VPC CIDR block"
}