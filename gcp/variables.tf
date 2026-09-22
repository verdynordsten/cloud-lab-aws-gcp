variable "project" {
  description = "GCP project id for the lab"
  type        = string
  default     = "my-lab-project"
}

variable "region" {
  description = "GCP region for the lab"
  type        = string
  default     = "asia-southeast1"
}

variable "name" {
  description = "lab name prefix (lowercase, no spaces)"
  type        = string
  default     = "cloudlab"
}

variable "suffix" {
  description = "unique suffix for the bucket (buckets are global)"
  type        = string
  default     = "verdy01"
}

variable "machine_type" {
  description = "Compute size — keep on lab list (e2-micro, e2-small)"
  type        = string
  default     = "e2-micro"
}
