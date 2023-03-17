provider "google" {
  project = var.project
  region  = var.region
  zone    = "us-central1-c"
}

provider "google-beta" {
  project = var.project
  region  = var.region
  zone    = "us-central1-c"
}

data "terraform_remote_state" "vpc" {
  backend = "local"

  config = {
    path = "${path.module}/../vpc-instances/terraform.tfstate"
  }
}

resource "google_compute_global_address" "private_ip_address" {
  provider = google-beta

  name          = "private-ip-address"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = data.terraform_remote_state.vpc.outputs.vpc-id
}

resource "google_service_networking_connection" "private_vpc_connection" {
  provider = google-beta

  network                 = data.terraform_remote_state.vpc.outputs.vpc-id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_address.name]
}

resource "google_sql_database_instance" "mysql-main" {
  provider         = google-beta
  name             = "mysql-main"
  region           = var.region
  database_version = "MYSQL_8_0"

  depends_on = [google_service_networking_connection.private_vpc_connection]

  settings {
    tier = "db-f1-micro"
    deletion_protection_enabled = false

    database_flags {
      name  = "cloudsql_iam_authentication"
      value = "on"
    }

    ip_configuration {
      ipv4_enabled    = false
      private_network = data.terraform_remote_state.vpc.outputs.vpc-id
    }
  }
}

resource "google_sql_ssl_cert" "client_cert" {
  common_name = "client-name"
  instance    = google_sql_database_instance.mysql-main.name
}

resource "google_sql_user" "self" {
  name     = "jgriggs-admin@griggsco.io"
  instance = google_sql_database_instance.mysql-main.name
  type     = "CLOUD_IAM_USER"
}

resource "google_sql_user" "users" {
  name     = "dbadmin"
  instance = google_sql_database_instance.mysql-main.name
  host = "%"
  password = var.dbpassword
}
