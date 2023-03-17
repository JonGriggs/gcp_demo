resource "google_compute_firewall" "griggsco-fwall-ssh" {
  name = "griggsco-ssh"
  network = google_compute_network.vpc_network.name
  
  source_ranges = [var.allowed_ip]

  allow {
    protocol = "tcp"
    ports = ["22"]
  }
}

resource "google_compute_firewall" "griggsco-fwall-web" {
  name = "griggsco-web"
  network = google_compute_network.vpc_network.name
  
  source_ranges = [var.allowed_ip]

  allow {
    protocol = "tcp"
    ports = ["80", "443", "3306"]
  }
}

resource "google_compute_firewall" "griggsco-egress" {
  name = "griggsco-egress"
  network = google_compute_network.vpc_network.name
  direction = "EGRESS"
  
  destination_ranges = ["0.0.0.0/0"]

  allow {
    protocol = "all"
  }
}

resource "google_compute_firewall" "ping" {
  name    = "ping"
  network = google_compute_network.vpc_network.name
  source_ranges = ["10.50.0.0/22", "10.150.0.0/22"]

  allow {
    protocol = "icmp"
  }
}

resource "google_compute_route" "internet-route" {
  name        = "egress-route"
  dest_range  = "0.0.0.0/0"
  network     = google_compute_network.vpc_network.name
  next_hop_gateway = "default-internet-gateway"
  priority    = 100
}
