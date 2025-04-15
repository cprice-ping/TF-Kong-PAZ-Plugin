variable "namespace" {
  type        = string
  description = "The Kubernetes namespace to deploy into."
}

variable "deployName" {
  type        = string
  description = "The name of this deployment"
}

variable "deployDomain" {
  type        = string
  description = "The DNS domain of this deployment"
}

variable "kongName" {
  type        = string
  description = "The name of this deployment"
}

variable "externalUrl" {
  type        = string
  description = "External FQDN of PingAuthorize"
}

variable "oidcWellKnownEndpoint" {
  type        = string
  description = "PAP OIDC provider - OIDC .well-known URL"
}

variable "clientId" {
  type        = string
  description = "PAP OIDC provider - OIDC Web Client ID"
}

variable "papSharedSecret" {
  type        = string
  description = "Shared Secret between PAZ and PAP"
  sensitive = true
}

variable "pluginSharedSecret" {
  type        = string
  description = "Shared Secret between PAZ and Kong ping-auth plugin"
  sensitive = true
}

# PingOne
# Used for OIDC into PAP, and PAZ ATV config
variable "regionCode" {
  type        = string
  description = "Environment Region"
}

variable "organizationId" {
  type        = string
  description = "Organization ID"
}

variable "licenseName" {
  type        = string
  description = "License Name"
}

variable "environmentId" {
  type        = string
  description = "Environment ID where Worker is"
  sensitive = true
}

variable "workerId" {
  type        = string
  description = "P1 Worker ID"
}

variable "workerSecret" {
  type        = string
  description = "P1 Worker Secret"
  sensitive = true
}

variable "adminUserName" {
  type = string
}

locals {
  # Translate the Region to a Domain suffix
  north_america  = var.regionCode == "NA" ? "com" : ""
  europe         = var.regionCode == "EU" ? "eu" : ""
  canada         = var.regionCode == "CA" ? "ca" : ""
  asia_pacific   = var.regionCode == "AP" ? "asia" : ""
  australia = var.regionCode == "AU" ? "com.au" : ""
  pingone_domain = coalesce(local.north_america, local.europe, local.canada, local.asia_pacific, local.australia)
}