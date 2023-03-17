provider "google" {
  project = var.project
  region  = var.region
  zone    = "us-central1-c"
}

provider "random" {}

data "terraform_remote_state" "vpc" {
  backend = "local"

  config = {
    path = "${path.module}/../vpc-instances/terraform.tfstate"
  }
}

## Storage encryption
resource "google_kms_key_ring" "storage" {
  name     = "keyring-storage"
  location = var.region
}

## Key
resource "google_kms_crypto_key" "bucket-key" {
  name     = "bucket-key"
  key_ring = google_kms_key_ring.storage.id
  purpose  = "ENCRYPT_DECRYPT"
}

data "google_storage_project_service_account" "gcs_account" {
}

resource "google_kms_crypto_key_iam_binding" "binding" {
  crypto_key_id = google_kms_crypto_key.bucket-key.id
  role          = "roles/cloudkms.cryptoKeyEncrypterDecrypter"

  members = ["serviceAccount:${data.google_storage_project_service_account.gcs_account.email_address}", "serviceAccount:${data.terraform_remote_state.vpc.outputs.instance-service-account}"]
}

resource "random_string" "random" {
  length  = 4
  special = false
  lower   = true
  upper   = false
}

resource "google_storage_bucket" "test-bucket" {
  name          = "griggsco-storage-${random_string.random.result}"
  location      = var.region
  force_destroy = true

  encryption {
    default_kms_key_name = google_kms_crypto_key.bucket-key.id
  }

  depends_on = [google_kms_crypto_key_iam_binding.binding]
}

data "google_iam_policy" "test-bucket-policy" {
  binding {
    role    = "roles/storage.objectViewer"
    members = ["serviceAccount:${data.terraform_remote_state.vpc.outputs.instance-service-account}"]
  }

  binding {
    role    = "roles/storage.objectCreator"
    members = ["serviceAccount:${data.terraform_remote_state.vpc.outputs.instance-service-account}"]
  }
}

resource "google_storage_bucket_iam_policy" "test-bucket-iam" {
  bucket = google_storage_bucket.test-bucket.name
  policy_data = data.google_iam_policy.test-bucket-policy.policy_data
}
