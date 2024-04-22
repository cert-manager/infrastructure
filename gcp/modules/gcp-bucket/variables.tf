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

# TODO: remove this once we resolve the rclone issues
# see https://github.com/cert-manager/cert-manager/pull/6906
variable "uniform_bucket_level_access" {
  type    = bool
  default = true
}