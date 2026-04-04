terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.36.0"
    }
  }

  backend "s3" {
    endpoints = {
      s3 = "https://fra1.digitaloceanspaces.com"
    }
    region                      = "us-east-1"
    bucket                      = "levko-tfstate-exam"
    key                         = "task1/terraform.tfstate"
    skip_credentials_validation = true
    skip_region_validation      = true
    skip_metadata_api_check     = true
    skip_requesting_account_id  = true  # Ось ця стрічка виправляє головну помилку
    skip_s3_checksum            = true  # Ця стрічка теж важлива для DO Spaces
  }
}

provider "digitalocean" {
  # Токен буде братися з системної змінної DIGITALOCEAN_TOKEN
}