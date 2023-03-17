provider "google" {
  project = var.project
  region  = var.region
  zone    = "us-central1-c"
}

resource "google_compute_network" "vpc_network" {
  name                            = "griggsco-vpc"
  auto_create_subnetworks         = false
  delete_default_routes_on_create = true
}

resource "google_compute_subnetwork" "app-subnet-central" {
  name          = "griggsco-central"
  ip_cidr_range = "10.50.0.0/22"
  region        = var.region
  network       = google_compute_network.vpc_network.id
}

resource "google_compute_subnetwork" "app-subnet-west" {
  name          = "griggsco-west"
  ip_cidr_range = "10.150.0.0/22"
  region        = "us-west1"
  network       = google_compute_network.vpc_network.id
}

resource "google_compute_address" "static" {
  name       = "vm-public-address"
  project    = var.project
  region     = var.region
  depends_on = [google_compute_firewall.griggsco-fwall-ssh]
}

resource "google_compute_address" "static2" {
  name       = "vm-public-address2"
  project    = var.project
  region     = var.region
  depends_on = [google_compute_firewall.griggsco-fwall-ssh]
}

resource "google_compute_address" "static-w" {
  name       = "vm-public-address"
  project    = var.project
  region     = "us-west1"
  depends_on = [google_compute_firewall.griggsco-fwall-ssh]
}

resource "google_compute_instance" "dev" {
  name                      = "devserver"
  machine_type              = "e2-medium"
  zone                      = "${var.region}-a"
  tags                      = ["externalssh", "webserver"]
  allow_stopping_for_update = true
  metadata_startup_script   = file("config_apache.sh")

  boot_disk {
    initialize_params {
      image = "centos-cloud/centos-7"
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.app-subnet-central.id
    access_config {
      nat_ip = google_compute_address.static.address
    }
  }

  service_account {
    email = google_service_account.instance-account.email

    scopes = [
      "https://www.googleapis.com/auth/devstorage.read_write",
      "https://www.googleapis.com/auth/cloudkms",
    ]
  }

  metadata = {
    enable-oslogin : "TRUE"
  }
}

resource "google_compute_instance" "dev-w" {
  name                      = "devserver"
  machine_type              = "e2-medium"
  zone                      = "us-west1-a"
  tags                      = ["externalssh", "webserver"]
  allow_stopping_for_update = true
  metadata_startup_script   = file("config_apache.sh")

  boot_disk {
    initialize_params {
      image = "centos-cloud/centos-7"
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.app-subnet-west.id
    access_config {
      nat_ip = google_compute_address.static-w.address
    }
  }

  service_account {
    email = google_service_account.instance-account.email

    scopes = [
      "https://www.googleapis.com/auth/devstorage.read_write",
      "https://www.googleapis.com/auth/cloudkms",
    ]
  }

  metadata = {
    enable-oslogin : "TRUE"
  }
}


data "google_client_openid_userinfo" "me" {
}

resource "google_os_login_ssh_public_key" "default" {
  user = data.google_client_openid_userinfo.me.email
  key  = file("../.ssh/id_rsa.pub") # path/to/ssl/id_rsa.pub
}
