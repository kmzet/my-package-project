# GDCV Migration: Secret-less Auth PoC

This project demonstrates a secure, identity-based migration path from external registries to Google Artifact Registry (GAR) for GDCV/GKE environments.

## 🚀 Prerequisites
1. **GCP Project**: `YOUR GCP PROJECT`
2. **Workload Identity Pool**: `YOUR github-pool`
3. **Artifact Registry**: `YOUR gdcv-images`

## 🛠️ One-Time Cloud Setup
Run these in Google Cloud Shell to build the "Trust Bridge":

```bash
# 1. Create the Auth Pool
gcloud iam workload-identity-pools create "github-pool" --location="global"

# 2. Link GitHub to the Pool (Replace YOUR_USER)
gcloud iam workload-identity-pools providers create-oidc "github-provider" \
    --location="global" \
    --workload-identity-pool="github-pool" \
    --issuer-uri="[https://token.actions.githubusercontent.com](https://token.actions.githubusercontent.com)" \
    --attribute-mapping="google.subject=assertion.sub,attribute.repository=assertion.repository" \
    --attribute-condition="assertion.repository_owner == 'YOUR GITHUB USERNAME'" //The attribute-condition ensures that even if someone knows your Project Number, only repositories under your specific GitHub username can authenticate.

# 3. Allow GitHub to act as the Service Account
gcloud iam service-accounts add-iam-policy-binding "github-migrator-sa@YOUR-GCP-PROJECT-ID.iam.gserviceaccount.com" \
    --role="roles/iam.workloadIdentityUser" \
    --member="principalSet://[iam.googleapis.com/projects/YOUR-PROJECT-NUMBER/locations/global/workloadIdentityPools/github-pool/attribute.repository/YOUR-GITHUB-USERNAME/my-package-project](https://iam.googleapis.com/projects/YOUR-PROJECT-NUMBER/locations/global/workloadIdentityPools/github-pool/attribute.repository/YOUR-GITHUB-USERNAME/my-package-project)"

# 4. Allow the identity to generate access tokens (Crucial for Docker Auth)
gcloud iam service-accounts add-iam-policy-binding "github-migrator-sa@YOUR-PROJECT-ID.iam.gserviceaccount.com" \
    --role="roles/iam.serviceAccountTokenCreator" \
    --member="principalSet://iam.googleapis.com/projects/YOUR-PROJECT-NUMBER/locations/global/workloadIdentityPools/github-pool/attribute.repository/YOUR-GITHUB-USERNAME/my-package-project"

## Artifactory to GAR Migration
To replicate this with existing JFrog workloads, follow the "Pull-Tag-Push" pattern or use the GCRane tool for large-scale migrations.

### 1. Authenticate to both Registries
```bash
# Auth to JFrog
docker login [JFROG_URL]

# Auth to Google Artifact Registry (Secret-less)
gcloud auth configure-docker us-central1-docker.pkg.dev

# Pull from JFrog
docker pull [JFROG_URL]/my-app:v1

# Retag for Google
docker tag [JFROG_URL]/my-app:v1 us-central1-docker.pkg.dev/gke-kueue/gdcv-images/my-app:v1

# Push to GAR
docker push us-central1-docker.pkg.dev/gke-kueue/gdcv-images/my-app:v1

For hundreds of images gcrane can be used to sync registries directly 
