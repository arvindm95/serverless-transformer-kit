
variable "project_id" {}
variable "app_version" {}

resource "google_sql_database_instance" "db_instance" {
  name   = "cloudrun-sql-stk"
  region = "us-central1"
  settings {
    tier = "db-f1-micro"
  }
}

resource "google_sql_user" "user" {
  name     = "adminuser" # database username
  instance = google_sql_database_instance.db_instance.name
  password = "password" # database password
}

resource "google_sql_database" "database" {
  name     = "database-stk" # Provide the name of your application database
  instance = google_sql_database_instance.db_instance.name
}

resource "google_cloud_run_service" "service_1" {
  name     = "cloudrun-service-stk"
  location = "us-central1"

  template {
    spec {
      containers {
        image = "gcr.io/${var.project_id}/service:${var.app_version}"
        env {
          name = "DATABASE_CONNECTION_NAME"
          value = google_sql_database_instance.db_instance.connection_name
        }
        env {
          name = "DATABASE_NAME"
          value = google_sql_database.database.name
        }
        env {
          name = "DATABASE_USERNAME"
          value = google_sql_user.user.name
        }
        env {
          name = "DATABASE_PASSWORD"
          value = google_sql_user.user.password
        }
        # modify the limits as needed for your application
        resources {
          limits = {
            memory = "1024M" 
            cpu = "1000m"
          }
        }
      }
    }
    metadata {
      annotations = {
        "autoscaling.knative.dev/maxScale"      = "1000"
        "run.googleapis.com/cloudsql-instances" = "${var.project_id}:us-central1:${google_sql_database_instance.db_instance.name}"
        "run.googleapis.com/client-name"        = "cloud-console"
      }
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }
}

data "google_iam_policy" "noauth" {
  binding {
    role = "roles/run.invoker"
    members = [
      "allUsers",
    ]
  }
}

resource "google_cloud_run_service_iam_policy" "noauth" {
  location    = google_cloud_run_service.service_1.location
  project     = google_cloud_run_service.service_1.project
  service     = google_cloud_run_service.service_1.name
  policy_data = data.google_iam_policy.noauth.policy_data
}

output "servicename" {
  value       = google_cloud_run_service.service_1.status[0].url
  description = "Service Url"
}