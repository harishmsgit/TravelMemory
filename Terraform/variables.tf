variable "aws_region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "ap-south-1"
}

variable "public_cidr" {
  description = "CIDR for the public subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "private_cidr" {
  description = "CIDR for the private subnet"
  type        = string
  default     = "10.0.2.0/24"
}

variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
  default     = "10.0.0.0/16"
}

variable "instance_type_web" {
  type    = string
  default = "t3.micro"
}

variable "instance_type_db" {
  type    = string
  default = "t3.micro"
}

variable "key_name" {
  description = "Existing EC2 Key Pair name for SSH access"
  type        = string
}

variable "admin_cidr" {
  description = "Your admin public IP/CIDR for SSH access"
  type        = string
}

variable "tags" {
  type = map(string)
  default = {
    Project = "TravelMemory"
    Owner   = "devops"
  }
}
