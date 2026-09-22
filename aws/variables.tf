variable "region" {
  description = "AWS region for the lab"
  type        = string
  default     = "ap-southeast-1"
}

variable "name" {
  description = "lab name prefix (lowercase, no spaces)"
  type        = string
  default     = "cloudlab"
}

variable "suffix" {
  description = "unique suffix for the S3 bucket (buckets are global)"
  type        = string
  default     = "verdy01"
}

variable "instance_type" {
  description = "EC2 size — keep on free-tier/lab list (t2.micro, t3.micro)"
  type        = string
  default     = "t3.micro"
}

variable "ami_id" {
  description = "Amazon Linux 2023 AMI for the region (see README to look yours up)"
  type        = string
  default     = "ami-0fa377abdf7...eplace"
}

variable "ssh_cidr" {
  description = "who may SSH in (your IP/32, never 0.0.0.0/0)"
  type        = string
  default     = "0..../32"
}
