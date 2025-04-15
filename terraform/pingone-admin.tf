data "pingone_environments" "administrators" {
  scim_filter = "(name sw \"Administrators\")"
}

# Get Admin Roles
data "pingone_role" "environment_admin" {
  name = "Environment Admin"
}

data "pingone_role" "identity_data_admin" {
  name = "Identity Data Admin"
}

data "pingone_role" "client_application_developer" {
  name = "Client Application Developer"
}

resource "pingone_group" "kong_token_env" {
  environment_id = data.pingone_environments.administrators.ids[0]

  name        = "Environment - ${pingone_environment.kong_token_provider.name}"
  description = "Admin access to Kong Token Env"

  lifecycle {
    # change the `prevent_destroy` parameter value to `true` to prevent this data carrying resource from being destroyed
    prevent_destroy = false
  }
}

resource "pingone_group_role_assignment" "env_admin" {
  environment_id = data.pingone_environments.administrators.ids[0]
  group_id       = pingone_group.kong_token_env.id
  role_id        = data.pingone_role.environment_admin.id

  scope_environment_id = pingone_environment.kong_token_provider.id
}

resource "pingone_group_role_assignment" "identity_admin" {
  environment_id = data.pingone_environments.administrators.ids[0]
  group_id       = pingone_group.kong_token_env.id
  role_id        = data.pingone_role.identity_data_admin.id

  scope_environment_id = pingone_environment.kong_token_provider.id
}

resource "pingone_group_role_assignment" "developer_admin" {
  environment_id = data.pingone_environments.administrators.ids[0]
  group_id       = pingone_group.kong_token_env.id
  role_id        = data.pingone_role.client_application_developer.id

  scope_environment_id = pingone_environment.kong_token_provider.id
}

data "pingone_user" "admin_username" {
  environment_id = data.pingone_environments.administrators.ids[0]

  email = var.adminUserName
}

resource "pingone_user_group_assignment" "kong_admin_group" {
  environment_id = data.pingone_environments.administrators.ids[0]

  user_id  = data.pingone_user.admin_username.id
  group_id = pingone_group.kong_token_env.id
}

# Create OIDC Login App for PAP
resource "pingone_application" "pap_logon" {
  environment_id = data.pingone_environments.administrators.ids[0]
  name           = "PAP Admin Login"
  enabled        = true

  oidc_options = {
    type                        = "WEB_APP"
    grant_types                 = ["AUTHORIZATION_CODE"]
    response_types              = ["CODE"]
    token_endpoint_auth_method = "NONE"
    redirect_uris              = ["https://${data.kubernetes_ingress_v1.pap_ingress.spec.0.rule.0.host}/idp-callback"]
    post_logout_redirect_uris = ["https://${data.kubernetes_ingress_v1.pap_ingress.spec.0.rule.0.host}" ]
  }
}

locals {
  openid_standard_scopes = [
    "email",
    "profile",
  ]
}

data "pingone_resource_scope" "openid_connect_standard_scope" {
  for_each = toset(local.openid_standard_scopes)

  environment_id = data.pingone_environments.administrators.ids[0]
  resource_type  = "OPENID_CONNECT"

  name = each.key
}

resource "pingone_application_resource_grant" "pap_login_openid_resource_grants" {
  environment_id = data.pingone_environments.administrators.ids[0]
  application_id = pingone_application.pap_logon.id

  resource_type = "OPENID_CONNECT"

  scopes = concat([
    for scope in data.pingone_resource_scope.openid_connect_standard_scope : scope.id
    ])
}

