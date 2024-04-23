variable "project_id" {
  description = "The project ID to use"
  type        = string
}
variable "location" {
  description = "The GCP location to use"
  type        = string
}

variable "bucket_name" {
  description = "The name of the bucket"
  type        = string
}
variable "bucket_versioned" {
  description = "Whether the bucket should be versioned"
  type        = bool
  default     = false
}
variable "bucket_prevent_public_access" {
  description = "The public access prevention setting for the bucket"
  type        = bool
  default     = true
}
variable "bucket_viewers" {
  type    = set(string)
  default = []
}
variable "bucket_admins" {
  type    = set(string)
  default = []
}
