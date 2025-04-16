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

