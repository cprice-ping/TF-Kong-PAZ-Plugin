resource "helm_release" "paz" {
  name       = "${var.deployName}"
  repository = "https://helm.pingidentity.com/"
  chart      = "ping-devops"
  namespace  = var.namespace

  values = [
    templatefile("paz.yaml.tpl", {
      externalUrl = data.kubernetes_ingress_v1.pap_ingress.spec.0.rule.0.host,
      defaultDomain = var.deployDomain,
      oidcWellKnownEndpoint = "https://auth.pingone.${local.pingone_domain}/${data.pingone_environments.administrators.ids[0]}/as/.well-known/openid-configuration"
      clientId = pingone_application.pap_logon.id
      papSharedSecret = var.papSharedSecret,
      pluginSharedSecret = var.pluginSharedSecret
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