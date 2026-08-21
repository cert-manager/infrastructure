output "workload_pool" {
  value = local.workload_pool
}

output "worker_pool_sa_member" {
  value = google_service_account.worker_pool_sa.member
}

output "credentialed_pool_sa_member" {
  value = var.credentialed_node_config == null ? null : google_service_account.credentialed_pool_sa[0].member
}
