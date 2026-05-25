output "workload_pool" {
  value = local.workload_pool
}

output "worker_pool_sa_member" {
  value = google_service_account.worker_pool_sa.member
}
