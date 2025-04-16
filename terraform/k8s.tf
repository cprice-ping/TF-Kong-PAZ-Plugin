terraform {
  required_providers {
    pingone = {
      source = "pingidentity/pingone"
    }
  }
}

provider "kubernetes" {
  config_path = "~/.kube/config"
}

provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}

provider "pingone" {
  client_id      = var.workerId
  client_secret  = var.workerSecret
  environment_id = var.environmentId
  region_code    = var.regionCode
}