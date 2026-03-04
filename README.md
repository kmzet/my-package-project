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
    --attribute-condition="assertion.repository_owner == 'YOUR GITHUB USERNAME'"

# 3. Allow GitHub to act as the Service Account
gcloud iam service-accounts add-iam-policy-binding "github-migrator-sa@YOUR-GCP-PROJECT-ID.iam.gserviceaccount.com" \
    --role="roles/iam.workloadIdentityUser" \
    --member="principalSet://[iam.googleapis.com/projects/YOUR-PROJECT-NUMBER/locations/global/workloadIdentityPools/github-pool/attribute.repository/YOUR-GITHUB-USERNAME/my-package-project](https://iam.googleapis.com/projects/YOUR-PROJECT-NUMBER/locations/global/workloadIdentityPools/github-pool/attribute.repository/YOUR-GITHUB-USERNAME/my-package-project)"
