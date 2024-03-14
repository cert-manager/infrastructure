variable "project_name" {
  description = "The name of the project to create"
  type        = string
}
variable "project_id" {
  description = "The project ID to use"
  type        = string
}
variable "project_folder_id" {
  description = "The folder to create the project under"
  type        = string
}
variable "project_billing_id" {
  description = "The billing account to associate with the project"
  type        = string
}
variable "project_owners" {
  type    = set(string)
  default = []
}

variable "project_apis" {
  type    = set(string)
  default = []
}
