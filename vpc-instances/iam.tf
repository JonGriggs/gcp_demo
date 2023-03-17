resource "google_compute_instance_iam_binding" "binding" {
  project = google_compute_instance.dev.project
  zone = google_compute_instance.dev.zone
  instance_name = google_compute_instance.dev.name
  role = "roles/compute.osLogin"
  members = [
    "user:jgriggs-admin@griggsco.io",
  ]
}

resource "google_compute_instance_iam_binding" "binding-admin" {
  project = google_compute_instance.dev.project
  zone = google_compute_instance.dev.zone
  instance_name = google_compute_instance.dev.name
  role = "roles/compute.osAdminLogin"
  members = [
    "user:jgriggs-admin@griggsco.io",
  ]
}

resource "google_service_account" "instance-account" {
  account_id = "instance-account"
  display_name = "Service Account for instances"
}
