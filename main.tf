#################################################################################
#--------------------------------PROVIDER---------------------------------------#
#################################################################################
provider "google" {
    credentials     = "${file("~/Téléchargements/fabled-orbit-241907-8faacd98a4cf.json")}"
    project         = "${var.projet}"
    region          = "${var.region}"
    zone            = "${var.zone}"
}

#################################################################################
#--------------------------------VNET-------------------------------------------#
#################################################################################
resource "google_compute_network" "vnet" {
  name = "project-vnet"
  auto_create_subnetworks = false
}

#################################################################################
#--------------------------------SUBNET-----------------------------------------#
#################################################################################
resource "google_compute_subnetwork" "jenkins-nexus" {
  name          = "jenins-nexus"
  ip_cidr_range = "10.2.0.0/16"
  region        = "${var.region}"
  network       = "${google_compute_network.vnet.self_link}"
}

resource "google_compute_subnetwork" "kub-docker" {
  name          = "kub-docker"
  ip_cidr_range = "10.3.0.0/16"
  region        = "${var.region}"
  network       = "${google_compute_network.vnet.self_link}"
}

#################################################################################
#--------------------------------FIREWALL---------------------------------------#
#################################################################################
resource "google_compute_firewall" "ssh-firewall" {
  name    = "ssh-firewall"
  network = "${google_compute_network.vnet.name}"

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  priority      = 1000
  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "egress-firewall" {
  name    = "egress-firewall"
  network = "${google_compute_network.vnet.name}"

  direction  = "EGRESS"
  priority   = 1001
  allow {
    protocol = "tcp"
  }
}

resource "google_compute_firewall" "kub-firewall" {
  name    = "kub-firewall"
  network = "${google_compute_network.vnet.name}"

  priority   = 1002
  source_ranges = ["0.0.0.0/0"]

  allow {
    protocol = "tcp"
    ports    = ["443"]
  }
}

resource "google_compute_firewall" "jenkins-firewall" {
  name    = "jenkins-firewall"
  network = "${google_compute_network.vnet.name}"

  priority   = 1003
  source_ranges = ["0.0.0.0/0"]

  allow {
    protocol = "tcp"
    ports    = ["8080"]
  }
}

resource "google_compute_firewall" "nexus-firewall" {
  name    = "nexus-firewall"
  network = "${google_compute_network.vnet.name}"

  priority   = 1004
  source_ranges = ["0.0.0.0/0"]

  allow {
    protocol = "tcp"
    ports    = ["8081"]
  }
}

#################################################################################
#--------------------------------PROXY------------------------------------------#
#################################################################################

resource "google_compute_target_http_proxy" "default" {
  name        = "project-proxy"
  url_map     = "${google_compute_url_map.default.self_link}"
}

resource "google_compute_url_map" "default" {
  name        = "url-map"
  default_service = "${google_compute_backend_service.default.self_link}"

  host_rule {
    hosts        = ["*"]
    path_matcher = "allpaths"
  }

  path_matcher {
    name            = "allpaths"
    default_service = "${google_compute_backend_service.default.self_link}"

    path_rule {
      paths   = ["/*"]
      service = "${google_compute_backend_service.default.self_link}"
    }
  }
}

resource "google_compute_backend_service" "default" {
  name        = "backend-service"
  port_name   = "http"
  protocol    = "HTTP"
  timeout_sec = 10

  health_checks = ["${google_compute_http_health_check.default.self_link}"]
}

resource "google_compute_http_health_check" "default" {
  name               = "http-health-check"
  request_path       = "/"
  check_interval_sec = 1
  timeout_sec        = 1
}


#################################################################################
#--------------------------------CLUSTER ---------------------------------------#
#################################################################################
resource "google_container_cluster" "primary" {
  name     = "my-gke-cluster"
  location = "${var.zone}"
  network    = "${google_compute_network.vnet.self_link}"
  subnetwork = "${google_compute_subnetwork.kub-docker.self_link}"

  # We can't create a cluster with no node pool defined, but we want to only use
  # separately managed node pools. So we create the smallest possible default
  # node pool and immediately delete it.
  remove_default_node_pool = true
  initial_node_count = 1

  ip_allocation_policy {
    node_ipv4_cidr_block = "10.3.0.0/16"
  }

  private_cluster_config {
    master_ipv4_cidr_block = "10.4.0.0/28"
    enable_private_nodes = true
    enable_private_endpoint = true
  }

  master_authorized_networks_config {
      cidr_blocks {
          cidr_block = "10.2.0.0/16"
          display_name = "admin-subnet"
      }

      cidr_blocks {
          cidr_block = "10.3.0.0/16"
          display_name = "nodes-subnet"
      }
  }

  # Setting an empty username and password explicitly disables basic auth
  master_auth {
    username = ""
    password = ""
  }
  node_config {
    tags = ["master"]
  }
}

#################################################################################
#--------------------------------NODE POOL--------------------------------------#
#################################################################################
resource "google_container_node_pool" "primary_stateful_nodes" {
  name       = "my-node-pool1"
  location   = "${var.zone}"
  cluster    = "${google_container_cluster.primary.name}"
  node_count = 1

  node_config {
    preemptible  = true
    machine_type = "n1-standard-1"

    metadata {
      disable-legacy-endpoints = "true"
      type                     = "stateful"
    }

    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]
  }
}

resource "google_container_node_pool" "primary_stateless_nodes2" {
  name       = "my-node-pool2"
  location   = "${var.zone}"
  cluster    = "${google_container_cluster.primary.name}"
  node_count = 1

  node_config {
    preemptible  = true
    machine_type = "n1-standard-1"

    metadata {
      disable-legacy-endpoints = "true"
      type                     = "stateless"
    }

    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]
  }
}

#################################################################################
#--------------------------------INSTANCE---------------------------------------#
#################################################################################

#Machine contenant le client Kubectl
resource "google_compute_instance" "kub" {
  name         = "kub"
  machine_type = "f1-micro"

  boot_disk {
    initialize_params {
      image = "centos-7"
    }
  }

  network_interface {
    network       = "${google_compute_network.vnet.self_link}"
    subnetwork       = "${google_compute_subnetwork.kub-docker.self_link}"
    access_config {

    }
  }

  metadata {
    sshKeys = "${var.gce_ssh_user}:${file(var.gce_ssh_pub_key_file)}"
  }
}

#Machine Nexus
resource "google_compute_instance" "nexus" {
  name         = "nexus"
  machine_type = "f1-micro"

  boot_disk {
    initialize_params {
      image = "centos-7"
    }
  }

  network_interface {
    network       = "${google_compute_network.vnet.self_link}"
    subnetwork       = "${google_compute_subnetwork.jenkins-nexus.self_link}"
    access_config {

    }
  }

  metadata {
    sshKeys = "${var.gce_ssh_user}:${file(var.gce_ssh_pub_key_file)}"
  }
}

#Machine Jenkins
resource "google_compute_instance" "jenkins" {
  name         = "jenkins"
  machine_type = "f1-micro"

  boot_disk {
    initialize_params {
      image = "centos-7"
    }
  }

  network_interface {
    network       = "${google_compute_network.vnet.self_link}"
    subnetwork       = "${google_compute_subnetwork.jenkins-nexus.self_link}"
    access_config {

    }
  }

  metadata {
    sshKeys = "${var.gce_ssh_user}:${file(var.gce_ssh_pub_key_file)}"
  }
}

#Machine Docker
resource "google_compute_instance" "docker" {
  name         = "docker"
  machine_type = "f1-micro"

  boot_disk {
    initialize_params {
      image = "centos-7"
    }
  }

  network_interface {
    network       = "${google_compute_network.vnet.self_link}"
    subnetwork       = "${google_compute_subnetwork.kub-docker.self_link}"
    access_config {

    }
  }

  metadata {
    sshKeys = "${var.gce_ssh_user}:${file(var.gce_ssh_pub_key_file)}"
  }
}