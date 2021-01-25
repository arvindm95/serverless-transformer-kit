# Serverless Transformer Kit - Cloud Run + Cloud SQL + Cloud Build + Terraform

## CI/CD - Google Cloud Build - Setup using Terraform
Use the terraform code in the `gcp-cloud-build-tf` for this step.

### This terraform module creates the following resources:
    1. Cloud Build Trigger 
    2. IAM role binding with Cloud Build Service account.
        - roles/run.admin
        - roles/cloudsql.admin
        - roles/iam.serviceAccountUser
    3. A Cloud Storage Bucket to save the terraform state of the infra tf module.

### Pre Requisites
    1. A project with billing account attached on Google Cloud.

### Steps to perform before terraform execution
    1. Get the `PROJECT_ID` and `PROJECT_NUMBER` of the GCP project.
    2. Enable the following API's from the API's and Services menu,
        - Cloud Run API
        - Cloud Build API
        - Cloud SQL Admin API
        - Cloud Source Repositories API
    3. Go to Cloud Build -> Triggers. Click `Connect Repository`. Provide the authentication details with Github/Bitbucket and choose the trigger branch and strategy.
    4. Skip the Step 3, if you are gooing to use the Cloud Source Repository.
    5. Note down the Cloud Source repository name created in Step 3 (Mirrored repo would be created) or Step 4.
    6. Create a Service Account from the IAM Menu under the above project created. This is used for execting the CI/CD terraform for the first time. Service Account shoulld contain following roles,
        - Storage Admin
        - Security Admin
        - Cloud Build Editor
        - Cloud Build Service Account



### Create CI/CD using the tf from `gcp-cloud-build-tf` folder

```
terraform init

terraform plan -var repo_name=<SOURCE_REPO_NAME> -var project_number=<PROJECT_NUMBER> -var infra_tf_bucket=<GCS_BUCKET_NAME> -out plan

terraform apply plan
```

## Infrastructure Provisioning

### Copy the `Infra` folder and `cloudbuild.yaml` from this repo and place it on the root folder of your application.

    1. Copy `Infra` + `cloudbuild.yaml` -> Place it on the root folder of you application.
    2. Provide the Cloud Storage bucket name created to store the TF state on the `backend.tf` file.
    3. Push the code to repository.

    Now, go to the Cloud Build on the Google Cloud Console to check the status of the Build and once it is completed succesfully, you can get the Cloud Run service URL as output.
    Use this URL in your frontend code.

### Terraform module in Infra folder will create the following resources
    1. Cloud SQL Instance with Mysql Engine.
    2. MySql Database and a User.
    3. Cloud Run Service with SQL proxy connection to Cloud SQL instance.
    4. Service IAM policy to allow public access to invoke the Cloud Run service.

 ### Additional Notes
    1. The cloudbuild.yaml is configured to work with gradle projects. Refer this link `https://github.com/GoogleCloudPlatform/cloud-builders` for other supported builders like mvn, go, npm,...
    2. Cloud SQL uses unix socket based connections with Cloud Run and does not support tcp connections for now. Hence, an additional one line configuration is required for DB connection on the applications. Refer https://cloud.google.com/sql/docs/mysql/connect-run. 
    3. For Springboot projects, to perform Step 2, use `spring-cloud-gcp-starter-sql-mysql` plugin available for both gradle and maven projects.
        ```
        application.properties

        spring.datasource.username=${DATABASE_USERNAME}
        spring.datasource.password=${DATABASE_PASSWORD}
        spring.cloud.gcp.sql.database-name=${DATABASE_NAME}
        spring.cloud.gcp.sql.instance-connection-name=${DATABASE_CONNECTION_NAME}
        spring.cloud.gcp.sql.enabled=true
        ```
    4. Add the project name in `provider.tf` to point your GCP project.
