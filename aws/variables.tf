variable "region" {
  default = "us-east-2"
}

variable "vpc_name" {
  default = "k8s-vpc"
}

variable "vpc_cidr" {
  default = "172.16.0.0/16"
}

variable "vpc_private_subnets" {
  default = ["172.16.1.0/24", "172.16.2.0/24", "172.16.3.0/24"]
}

variable "vpc_public_subnets" {
  default = ["172.16.4.0/24", "172.16.5.0/24", "172.16.6.0/24"]
}

variable "eks_cluster_version" {
  default = "1.17"
}

variable "nodes_desired" {
  default = 1
}

variable "nodes_min" {
  default = 1
}

variable "nodes_max" {
  default = 3
}

variable "nodes_type" {
  default = "t2.small"
}

variable "write_kubeconfig" {
  default = true
}

variable "kubeconfig_path" {
  # path    = file("${path.module}/kubeconfig_cert-manager-cluster")
  default = "./kubeconfig_cert-manager-cluster"
  # default = "./kubeconfig_cert-manager-cluster"
}

variable "cert_manager_version" {
  default = "v1.3.1"
}
