terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.36.0"
    }
  }

  backend "s3" {
    endpoint                    = "fra1.digitaloceanspaces.com"
    region                      = "us-east-1" # Для DO Spaces завжди пишеться us-east-1 в конфігу
    bucket                      = "levko-tfstate-exam" # Наш ручний бакет
    key                         = "task1/terraform.tfstate"
    skip_credentials_validation = true
    skip_region_validation      = true
    skip_metadata_api_check     = true
  }
}

provider "digitalocean" {
  # Токен буде братися з системної змінної DIGITALOCEAN_TOKEN
}