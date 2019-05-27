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
  name = "kub-project-vnet"
  auto_create_subnetworks = false
}

#################################################################################
#--------------------------------SUBNET-----------------------------------------#
#################################################################################
resource "google_compute_subnetwork" "admin-subnet" {
  name          = "admin-subnet"
  ip_cidr_range = "10.2.0.0/16"
  region        = "${var.region}"
  network       = "${google_compute_network.vnet.self_link}"
}

resource "google_compute_subnetwork" "nodes-subnet" {
  name          = "nodes-subnet"
  ip_cidr_range = "10.3.0.0/16"
  region        = "${var.region}"
  network       = "${google_compute_network.vnet.self_link}"
}
#X

#################################################################################
#--------------------------------FIREWALL---------------------------------------#
#################################################################################
resource "google_compute_firewall" "firewall" {
  name    = "ssh-firewall"
  network = "${google_compute_network.vnet.name}"

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  priority      = 1000
  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "firewall" {
  name    = "egress-firewall"
  subnetwork = "${google_compute_subnetwork.admin-subnet.name}"

  direction  = "EGRESS"
  priority   = 1001
  allow {
    protocol = "tcp"
    ports    = ["*"]
  }
}
#X

#################################################################################
#--------------------------------CLUSTER ---------------------------------------#
#################################################################################
resource "google_container_cluster" "primary" {
  name     = "my-gke-cluster"
  location = "${var.region}"
  subnetwork = "${google_compute_subnetwork.nodes-subnet.self_link}"

  # We can't create a cluster with no node pool defined, but we want to only use
  # separately managed node pools. So we create the smallest possible default
  # node pool and immediately delete it.
  remove_default_node_pool = true
  initial_node_count = 1
  cluster_ipv4_cidr = "10.3.0.0/16"

  # Setting an empty username and password explicitly disables basic auth
  master_auth {
    username = "admin"
    password = "admin"
  }
}

#################################################################################
#--------------------------------NODE POOL--------------------------------------#
#################################################################################
resource "google_container_node_pool" "primary_preemptible_nodes" {
  name       = "my-node-pool1"
  location   = "${var.region}"
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

resource "google_container_node_pool" "primary_preemptible_nodes" {
  name       = "my-node-pool2"
  location   = "${var.region}"
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
resource "google_compute_instance" "admin" {
  name         = "admin"
  machine_type = "f1-micro"

  boot_disk {
    initialize_params {
      image = "centos-7"
    }
  }

  network_interface {
    # A default network is created for all GCP projects
    network       = "${google_compute_network.vnet.self_link}"
    subnetwork       = "${google_compute_subnetwork.admin-subnet.self_link}"
    access_config {

    }
  }

  metadata {
    sshKeys = "${var.gce_ssh_user}:${file(var.gce_ssh_pub_key_file)}"
  }
}
#X