
terraform {
  backend "gcs" {
    bucket = "cloud-run-service-tf-bk"
    # credentials = "./creds/sa.json" # Provide service account if you are working in local
  }
}