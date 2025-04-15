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
    } ]
    name = var.deployName
}

resource "pingone_population_default" "default_population" {
  environment_id = pingone_environment.kong_token_provider.id

  name        = "Default"
}

# Create OIDC Login App for PAP
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

locals {
  openid_standard_scopes_kong = [
    "email",
    "profile",
  ]
}

data "pingone_resource_scope" "openid_connect_standard_scope_kong" {
  for_each = toset(local.openid_standard_scopes_kong)

  environment_id = pingone_environment.kong_token_provider.id
  resource_type  = "OPENID_CONNECT"

  name = each.key
}

resource "pingone_application_resource_grant" "kong_token_resource_grants" {
  environment_id = pingone_environment.kong_token_provider.id
  application_id = pingone_application.kong_tokens.id

  resource_type = "OPENID_CONNECT"

  scopes = concat([
    for scope in data.pingone_resource_scope.openid_connect_standard_scope_kong : scope.id
    ])
}