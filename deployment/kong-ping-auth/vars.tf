variable "namespace" {
  type        = string
  description = "The Kubernetes namespace to deploy into."
}

variable "deployName" {
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