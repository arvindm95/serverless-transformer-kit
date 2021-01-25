provider "google" {
  project = "project-name-here"
#  credentials = file("./creds/sa.json") # Uncomment if you want to run on your local machine and provide the service account path. 
  region = "us-central1"
}
