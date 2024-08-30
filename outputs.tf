# Outputs
output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.govtech_vpc.id
}

output "public_subnet_ids" {
  description = "The IDs of the public subnets"
  value       = aws_subnet.public[*].id
}

output "private_ec2_subnet_ids" {
  description = "The IDs of the private EC2 subnets"
  value       = aws_subnet.private_ec2[*].id
}

output "private_db_subnet_ids" {
  description = "The IDs of the private DB subnets"
  value       = aws_subnet.private_db[*].id
}

output "ec2_instance_ids" {
  description = "The IDs of the EC2 instances"
  value       = aws_instance.app[*].id
}

output "db_instance_endpoints" {
  description = "The endpoints of the RDS instances"
  value       = aws_db_instance.db[*].endpoint
}

output "iam_role_arn" {
  description = "The ARN of the IAM role"
  value       = aws_iam_role.ec2_role.arn
}

output "iam_policy_arn" {
  description = "The ARN of the IAM policy"
  value       = aws_iam_policy.ec2_policy.arn
}

output "iam_instance_profile_arn" {
  description = "The ARN of the IAM instance profile"
  value       = aws_iam_instance_profile.ec2_instance_profile.arn
}
