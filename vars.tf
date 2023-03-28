variable "default_tags" {
  type = map(string)
  default = {
    "env" = "kinzh"
  }
  description = "kinzh variables decsription"
}

variable "public_subnet_count" {
  type        = number
  description = "public subnet count description (optional)"
  default     = 2
}