variable "aws_region" {
  description = "AWS region"
  type        = string
  validation {
    condition     = contains(["eu-west-1", "eu-central-1", "eu-south-1"], var.aws_region)
    error_message = "Invalid AWS Region"
  }
  default     = "eu-central-1"
}

variable "environment" {
  type        = string
  description = "Environment"
  validation {
    condition     = contains(["dev", "staging", "prod", "non-prod", "pre-prod"], var.environment)
    error_message = "Invalid environment"
  }
  default     = "dev"
}

variable "application_name" {
  description = "Application name"
  type        = string
  default     = "app-a"
}

variable "owner" {
  description = "Owner"
  type        = string
  default     = "owner"
}

# variable "s3_bucket_name" {
#   description = "S3 bucket name"
#   type        = string
#   default     = "tf-state"
