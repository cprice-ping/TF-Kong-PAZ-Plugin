resource "helm_release" "paz-pap" {
  name       = var.deployName
  repository = "https://helm.pingidentity.com/"
  chart      = "ping-devops"
  namespace  = var.namespace

  values = [
    templatefile("paz.yaml.tpl", {
      externalUrl           = "pingauthorizepap-${var.deployName}.${var.deployDomain}"
      defaultDomain         = var.deployDomain,
      oidcWellKnownEndpoint = "https://auth.pingone.${local.pingone_domain}/${data.pingone_environments.administrators.ids[0]}/as/.well-known/openid-configuration"
      clientId              = pingone_application.pap_logon.id
      papSharedSecret       = var.papSharedSecret
      pluginSharedSecret    = var.pluginSharedSecret
      oidcProvider = "https://auth.pingone.${local.pingone_domain}/${pingone_environment.kong_token_provider.id}/as/token"
    })
  ]
}

data "kubernetes_service" "paz_service" {
  metadata {
    namespace = var.namespace
    name      = "${var.deployName}-pingauthorize"
  }
}

data "kubernetes_ingress_v1" "pap_ingress" {
  metadata {
    namespace = var.namespace
    name      = "${var.deployName}-pingauthorizepap"
  }
}

# Create OIDC Login App for PAP
resource "pingone_application" "pap_logon" {
  environment_id = data.pingone_environments.administrators.ids[0]
  name           = "PAP Admin Login"
  enabled        = true

  oidc_options = {
    type                       = "WEB_APP"
    grant_types                = ["AUTHORIZATION_CODE"]
    response_types             = ["CODE"]
    token_endpoint_auth_method = "NONE"
    redirect_uris              = ["https://pingauthorizepap-${var.deployName}.${var.deployDomain}/idp-callback"]
    post_logout_redirect_uris  = ["https://pingauthorizepap-${var.deployName}.${var.deployDomain}"]
    cors_settings = {
      behavior = "ALLOW_SPECIFIC_ORIGINS"
      origins = ["https://pingauthorizepap-${var.deployName}.${var.deployDomain}"]
    }
  }
}

locals {
  openid_standard_scopes = [
    "email",
    "profile",
  ]

  depends_on = [helm_release.paz-pap]
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