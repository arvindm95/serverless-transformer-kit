
variable "project_number" {}

variable "repo_name" {}

variable "infra_tf_bucket" {}


resource "google_cloudbuild_trigger" "cloudbuild-trigger" {
    trigger_template {
        branch_name = "development" # give the branch name to watch for changes
        repo_name = var.repo_name
    }
    filename = "cloudbuild.yaml"
}

resource "google_project_iam_binding" "cloudrun-role" {
  role    = "roles/run.admin"

  members = [
    "serviceAccount:${var.project_number}@cloudbuild.gserviceaccount.com"
  ]
}

resource "google_project_iam_binding" "cloudsql-role" {
  role    = "roles/cloudsql.admin"

  members = [
    "serviceAccount:${var.project_number}@cloudbuild.gserviceaccount.com"
  ]
}

resource "google_project_iam_binding" "sa-user-role" {
  role    = "roles/iam.serviceAccountUser"

  members = [
    "serviceAccount:${var.project_number}@cloudbuild.gserviceaccount.com"
  ]
}

resource "google_storage_bucket" "infra-tf-backend-bucket"{
    name = var.infra_tf_bucket
    location = "US"
}
