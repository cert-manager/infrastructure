variable "folder_id" {
  description = "The folder ID (numeric)"
  type        = string
}

variable "folder_display_name" {
  description = "The display name of the folder"
  type        = string
}

variable "folder_parent" {
  description = "The parent resource (organizations/ORG_ID or folders/FOLDER_ID)"
  type        = string
}

variable "folder_iam" {
  description = "Authoritative IAM bindings for the folder. Map of role -> list of members."
  type        = map(list(string))
  default     = {}
}
