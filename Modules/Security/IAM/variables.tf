# IAM Role Configuration
variable "iam_role_name" {
  description = "Name of the IAM role"
  type        = string
  default     = "govtech-ec2-role"
}

variable "iam_policy_name" {
  description = "Name of the IAM policy"
  type        = string
  default     = "govtech-ec2-policy"
}
