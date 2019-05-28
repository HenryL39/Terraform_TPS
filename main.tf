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
resource "google_compute_firewall" "firewall1" {
  name    = "ssh-firewall"
  network = "${google_compute_network.vnet.name}"

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  priority      = 1000
  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "firewall2" {
  name    = "egress-firewall"
  network = "${google_compute_network.vnet.name}"

  direction  = "EGRESS"
  priority   = 1001
  allow {
    protocol = "tcp"
  }
}

resource "google_compute_firewall" "firewall3" {
  name    = "master-access-firewall"
  network = "${google_compute_network.vnet.name}"

  priority   = 1002
  source_ranges = ["0.0.0.0/0"]

  allow {
    protocol = "tcp"
    ports    = ["443"]
  }
}
#X

#################################################################################
#--------------------------------CLUSTER ---------------------------------------#
#################################################################################
resource "google_container_cluster" "primary" {
  name     = "my-gke-cluster"
  location = "${var.zone}"
  network    = "${google_compute_network.vnet.self_link}"
  subnetwork = "${google_compute_subnetwork.nodes-subnet.self_link}"

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