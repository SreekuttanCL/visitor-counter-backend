variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default      = "us-east-1"
}

variable "dynamodb_table_name" {
  description = "Visitor counter DynamoDB table name"
  type        = string
  default     = "visitor-counter"
}
