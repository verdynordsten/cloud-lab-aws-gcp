terraform {
  required_version = ">= 1.5"
  required_providers {
    google = { source = "hashicorp/google", version = "~> 5.0" }
  }
}

provider "google" {
  project = var.project
  region  = var.region
}

resource "google_compute_network" "lab" {
  name                    = "${var.name}-vpc"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "public" {
  name          = "${var.name}-subnet"
  ip_cidr_range = "10.20.1.0/24"
  region        = var.region
  network       = google_compute_network.lab.id
}

resource "google_compute_firewall" "web" {
  name    = "${var.name}-web"
  network = google_compute_network.lab.id
  allow {
    protocol = "tcp"
    ports    = ["22", "80"]
  }
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["lab-web"]
}

resource "google_compute_instance" "web" {
  name         = "${var.name}-web"
  machine_type = var.machine_type
  zone         = "${var.region}-a"
  tags         = ["lab-web"]
  boot_disk {
    initialize_params { image = "debian-cloud/debian-12" }
  }
  network_interface {
    subnetwork = google_compute_subnetwork.public.id
    access_config {}
  }
  metadata_startup_script = "apt-get update && apt-get install -y nginx && systemctl enable --now nginx"
}

resource "google_storage_bucket" "lab" {
  name          = "${var.name}-lab-${var.suffix}"
  location      = var.region
  force_destroy = true
  versioning { enabled = true }
}

output "instance_ip" {
  value = google_compute_instance.web.network_interface[0].access_config[0].nat_ip
}

output "bucket_name" {
  value = google_storage_bucket.lab.name
}
