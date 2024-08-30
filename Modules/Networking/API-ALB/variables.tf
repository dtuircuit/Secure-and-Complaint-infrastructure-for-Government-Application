# API Gateway and ALB Configuration
variable "api_gateway_name" {
  description = "Name of the API Gateway"
  type        = string
  default     = "govtech-api"
}

variable "alb_name" {
  description = "Name of the Application Load Balancer"
  type        = string
  default     = "govtech-alb"
}

variable "alb_internal" {
  description = "Whether the ALB is internal or external"
  type        = bool
  default     = false
}
