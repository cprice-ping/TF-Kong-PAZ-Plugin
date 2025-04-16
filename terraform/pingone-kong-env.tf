data "pingone_licenses" "find_license" {
  organization_id = var.organizationId

  data_filters = [
    {
      name   = "name"
      values = [var.licenseName]
    },
    {
      name   = "status"
      values = ["ACTIVE"]
    }
  ]
}

resource "pingone_environment" "kong_token_provider" {
    license_id = data.pingone_licenses.find_license.ids[0]
    services = [ {
      type = "SSO"
    },
    {
      type = "Authorize"
    } ]
    name = var.deployName
}

resource "pingone_population_default" "default_population" {
  environment_id = pingone_environment.kong_token_provider.id

  name        = "Default"
}

# Create Kong Token app
resource "pingone_application" "kong_tokens" {
  environment_id = pingone_environment.kong_token_provider.id
  name           = "Kong Tokens"
  enabled        = true

  oidc_options = {
    type                        = "WEB_APP"
    grant_types                 = ["AUTHORIZATION_CODE"]
    response_types              = ["CODE"]
    token_endpoint_auth_method = "NONE"
    redirect_uris              = ["https://decoder.pingidentity.cloud/oidc", "https://decoder.pingidentity.cloud/implicit", "https://decoder.pingidentity.cloud/hybrid"]
  }
}

# resource "pingone_application_resource_grant" "kong_token_resource_grants" {
#   environment_id = pingone_environment.kong_token_provider.id
#   application_id = pingone_application.kong_tokens.id

#   resource_type      = "CUSTOM"
#   custom_resource_id = pingone_resource.kong_resource.id

#   scopes = [
#     pingone_resource_scope.kong_resource_scope.id
#   ]
# }