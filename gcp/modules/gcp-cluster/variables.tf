variable "project_id" {
  description = "The project ID to use"
  type        = string
}
variable "gcp_region" {
  description = "The GCP region to use"
  type        = string
}
variable "location" {
  description = "The GCP location to use"
  type        = string
}

variable "cluster_name" {
  description = "The name of the GKE cluster"
  type        = string
}
variable "cluster_description" {
  description = "The description of the GKE cluster"
  type        = string
}
variable "cluster_enable_workload_identity" {
  description = "Whether to attach a workload pool to all Kubernetes service accounts"
  type        = bool
  default     = false
}
variable "cluster_enable_gateway_api" {
  description = "Whether to enable the Gateway API on the GKE cluster"
  type        = bool
  default     = false
}
variable "node_config" {
  description = "The node configuration for the GKE cluster"
  type = object({
    min_count = number
    max_count = number

    machine_type = string
    disk_size_gb = number
    disk_type    = string
    preemptible  = bool
  })
}

locals {
  workload_pool = var.cluster_enable_workload_identity ? "${var.project_id}.svc.id.goog" : null
}
