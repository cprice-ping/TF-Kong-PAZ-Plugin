resource "pingone_resource" "kong_resource" {
  environment_id = pingone_environment.kong_token_provider.id

  name        = "Kong Gateway"
  description = "Resources used with the Kong Gateway"

  audience                      = "${var.kongName}.${var.deployDomain}"
  access_token_validity_seconds = 3600
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
  for_each       = toset(local.kong_resource_scopes)
  environment_id = pingone_environment.kong_token_provider.id
  resource_id    = pingone_resource.kong_resource.id

  name = each.key
}

resource "pingone_application_resource_grant" "kong_token_resource_grants" {
  environment_id = pingone_environment.kong_token_provider.id
  application_id = pingone_application.kong_tokens.id

  resource_type      = "CUSTOM"
  custom_resource_id = pingone_resource.kong_resource.id

  scopes = concat([
    for scope in pingone_resource_scope.kong_resource_scope : scope.id
  ])
}

resource "pingone_application_resource" "kong_application_resource" {
  environment_id = pingone_environment.kong_token_provider.id
  resource_name  = pingone_resource.kong_resource.name

  name        = "Metadata"
  description = "Metadata API controls"
}

variable "kong_media_permissions" {
  type = map(object({
    action      = string
    description = string
  }))
  default = {
    "read" = {
      action      = "Read_All"
      description = "Read all Metadata"
    },
    "create" = {
      action      = "Read_One"
      description = "Read single Metadata object"
    },
  }
}

resource "pingone_application_resource_permission" "media_permissions" {
  for_each = var.kong_media_permissions

  environment_id          = pingone_environment.kong_token_provider.id
  application_resource_id = pingone_application_resource.kong_application_resource.id

  action      = each.value.action
  description = each.value.description
}

resource "pingone_authorize_api_service" "media_api_service" {
  environment_id = pingone_environment.kong_token_provider.id

  name = "Media API"

  base_urls = [
    "https://${var.kongName}.${var.deployDomain}/media",
  ]

  authorization_server = {
    resource_id = pingone_resource.kong_resource.id
    type        = "PINGONE_SSO"
  }
}

resource "pingone_authorize_api_service_operation" "media_metadata_operation" {
  environment_id = pingone_environment.kong_token_provider.id
  api_service_id = pingone_authorize_api_service.media_api_service.id

  name = "Metadata Endpoint"

  methods = [
    "GET"
  ]

  paths = [
    {
      pattern = "/metadata"
      type    = "EXACT"
    },
    {
      pattern = "/metadata/{id}"
      type    = "PARAMETER"
    },
  ]
}