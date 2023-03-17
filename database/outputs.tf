output "cert_sha1" {
  value = google_sql_ssl_cert.client_cert.sha1_fingerprint
  sensitive = true
}

output "cert_private_key" {
  value = google_sql_ssl_cert.client_cert.private_key
  sensitive = true
}

output "ca-cert" {
  value = google_sql_ssl_cert.client_cert.server_ca_cert
  sensitive = true
}

output "cert" {
  value = google_sql_ssl_cert.client_cert.cert
  sensitive = true
}

output "username" {
  value = google_sql_user.self.name
}
