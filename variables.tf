variable "default_tags" {
    default = "k8s-env"
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}