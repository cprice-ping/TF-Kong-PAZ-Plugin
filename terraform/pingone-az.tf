resource "pingone_resource" "kong_resource" {
  environment_id = pingone_environment.kong_token_provider.id

  name        = "Kong Gateway"
  description = "Resources used with the Kong Gateway"

  audience                      = "${var.kongName}.${var.deployDomain}"
  access_token_validity_seconds = 3600
}

resource "pingone_authorize_api_service" "kong_api_service" {
  environment_id = pingone_environment.kong_token_provider.id

  name = "Kong - API service"

  base_urls = [
    "https://${var.kongName}.${var.deployDomain}"
  ]

  authorization_server = {
    resource_id = pingone_resource.kong_resource.id
    type        = "PINGONE_SSO"
  }

  directory = {
    type = "PINGONE_SSO"
  }
}

resource "pingone_gateway" "kong_api_gateway" {
  environment_id = pingone_environment.kong_token_provider.id
  name           = "Kong API Gateway"
  enabled        = true

  type = "API_GATEWAY_INTEGRATION"
}

resource "pingone_gateway_credential" "kong_api_gateway" {
  environment_id = pingone_environment.kong_token_provider.id
  gateway_id     = pingone_gateway.kong_api_gateway.id
}

locals {
  kong_resource_scopes = [
    "kong_get",
    "kong_post",
    "kong_delete"
  ]
}

resource "pingone_resource_scope" "kong_resource_scope" {
    for_each = toset(local.kong_resource_scopes)
    environment_id = pingone_environment.kong_token_provider.id
    resource_id    = pingone_resource.kong_resource.id

    name = each.key
}