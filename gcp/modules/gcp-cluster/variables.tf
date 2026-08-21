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
variable "credentialed_node_config" {
  description = <<-EOT
    If set, creates an additional node pool, tainted and labeled
    dedicated=credentialed-jobs, for Prow jobs which have access to live
    credentials. Scheduling those jobs on their own nodes means a container
    escape from an ordinary job (e.g. a privileged presubmit running
    unreviewed PR code) cannot read their secrets via the node's kubelet
    credentials, which only grant access to secrets of pods scheduled on
    that node.
  EOT
  type = object({
    min_count = number
    max_count = number

    machine_type = string
    disk_size_gb = number
    disk_type    = string
    preemptible  = bool
  })
  default = null
}
