resource "google_compute_network" "task2-vpc" {
  name = "task2-vpc"
  auto_create_subnetworks = false
  routing_mode = "REGIONAL"
}

#subnet for vpc in terraform

resource "google_compute_subnetwork" "sub-task2" {
  name = "sub-task2"
  network = google_compute_network.task2-vpc.id
  ip_cidr_range = "10.138.5.0/24"
  region = "us-west4"
  private_ip_google_access = true
   }

 # Firewall rules  

resource "google_compute_firewall" "allow-http1" {
  name        = "allow-http1"
  description = "Allow HTTP traffic"
  network     = google_compute_network.task2-vpc.id
  direction   = "INGRESS"
  priority    = 1000

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  source_ranges = ["0.0.0.0/0"]

  target_tags = ["http-server"]
}

resource "google_compute_firewall" "allow-ssh1" {
  name        = "allow-ssh1"
  description = "Allow SSH traffic"
  network     = google_compute_network.task2-vpc.id
  direction   = "INGRESS"
  priority    = 1000

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]

  target_tags = ["ssh-server"]
}

resource "google_compute_firewall" "egress-allow1" {
  name        = "egress-allow1"
  description = "Allow all egress traffic"
  network     = google_compute_network.task2-vpc.id
  direction   = "EGRESS"
  priority    = 1000

  allow {
    protocol = "all"
  }

  destination_ranges = ["0.0.0.0/0"]

  target_tags = ["egress"]
}
 

resource "google_compute_instance" "task2-instance13" {
  boot_disk {
    auto_delete = true
    device_name = "task2-instance13"

    initialize_params {
      image = "projects/debian-cloud/global/images/debian-12-bookworm-v20240515"
      size  = 10
      type  = "pd-balanced"
    }

    mode = "READ_WRITE"
  }

  can_ip_forward      = false
  deletion_protection = false
  enable_display      = false

  labels = {
    goog-ec-src = "vm_add-tf"
  }

  machine_type = "e2-medium"

  metadata = {
    startup-script = "#League Of Shadows\n#!/bin/bash\n# Update and install Apache2\napt update\napt install -y apache2\n\n# Start and enable Apache2\nsystemctl start apache2\nsystemctl enable apache2\n\n# GCP Metadata server base URL and header\nMETADATA_URL=\"http://metadata.google.internal/computeMetadata/v1\"\nMETADATA_FLAVOR_HEADER=\"Metadata-Flavor: Google\"\n\n# Use curl to fetch instance metadata\nlocal_ipv4=$(curl -H \"$${METADATA_FLAVOR_HEADER}\" -s \"$${METADATA_URL}/instance/network-interfaces/0/ip\")\nzone=$(curl -H \"$${METADATA_FLAVOR_HEADER}\" -s \"$${METADATA_URL}/instance/zone\")\nproject_id=$(curl -H \"$${METADATA_FLAVOR_HEADER}\" -s \"$${METADATA_URL}/project/project-id\")\nnetwork_tags=$(curl -H \"$${METADATA_FLAVOR_HEADER}\" -s \"$${METADATA_URL}/instance/tags\")\n\n# Create a simple HTML page and include instance details\ncat <<EOF > /var/www/html/index.html\n<html><body>\n<h2>Welcome League Of Shadows. Where We Get things Done .</h2>\n<h3>Created with a direct input startup script!</h3>\n<p><b>Instance Name:</b> $(hostname -f)</p>\n<p><b>Instance Private IP Address: </b> $local_ipv4</p>\n<p><b>Zone: </b> $zone</p>\n<p><b>Project ID:</b> $project_id</p>\n<p><b>Network Tags:</b> $network_tags</p>\n</body></html>\nEOF"
  }

  name = "task2-instance11"

  network_interface {
    access_config {
      network_tier = "PREMIUM"
    }

    queue_count = 0
    stack_type  = "IPV4_ONLY"
    subnetwork  = "projects/optimal-drummer-416401/regions/us-west4/subnetworks/sub-task2"
  }

  scheduling {
    automatic_restart   = true
    on_host_maintenance = "MIGRATE"
    preemptible         = false
    provisioning_model  = "STANDARD"
  }

  service_account {
    email  = "sega-361@optimal-drummer-416401.iam.gserviceaccount.com"
    scopes = ["https://www.googleapis.com/auth/cloud-platform"]
  }

  shielded_instance_config {
    enable_integrity_monitoring = true
    enable_secure_boot          = false
    enable_vtpm                 = true
  }

  tags = ["http-server"]
  zone = "us-west4-c"
}

output "instance_public_ips" {
  value = {
    "us-west4-c" = "http://${google_compute_instance.task2-instance13.network_interface[0].access_config[0].nat_ip}"
  }
  description = "List of HTTP URLs for public IP addresses assigned to the instances."
}



