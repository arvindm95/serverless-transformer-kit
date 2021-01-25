provider "google" {
  project = "project-name-here"
  credentials = file("./creds/sa.json")  # replace the location to your service account
  region = "us-central1"
}