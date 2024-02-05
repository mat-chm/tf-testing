resource "google_service_account" "default" {
  account_id   = "gke-sa"
  display_name = "Terraform Managed SA - GKE"
  project = var.project_id

}

resource "google_container_cluster" "cluster" {

name               = "my-k8s-cluster"
location           = var.region
initial_node_count = 1
project = var.project_id

# Enable Workload Identity
workload_identity_config {
  workload_pool = "${var.project_id}.svc.id.goog"
}

deletion_protection = false

node_config {
  preemptible  = true

  service_account = google_service_account.default.email
  disk_size_gb = "20"
  disk_type = "pd-standard"
  machine_type = "e2-medium" 
  oauth_scopes = [
    "https://www.googleapis.com/auth/logging.write",
    "https://www.googleapis.com/auth/monitoring",
  ]

  metadata = {
    "disable-legacy-endpoints" = "true"
  }

  workload_metadata_config {
    mode = "GKE_METADATA"
  }

  labels = { # Update: Replace with desired labels
    "environment" = "test"
    "team"        = "devops"
  }
}

}

data "google_client_config" "provider" {}

data "google_container_cluster" "my_cluster" {
  name     = google_container_cluster.cluster.name
  location = var.region
  project = var.project_id
}
