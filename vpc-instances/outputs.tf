output "vpc-id" {
  value = google_compute_network.vpc_network.id
}

output "ip-central" {
  value = google_compute_instance.dev.network_interface[0].access_config[0].nat_ip
}

output "ip-west" {
  value = google_compute_instance.dev-w.network_interface[0].access_config[0].nat_ip
}

output "instance-service-account" {
  value = google_service_account.instance-account.email
}
