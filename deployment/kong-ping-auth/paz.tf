resource "helm_release" "paz" {
  name       = "${var.deployName}"
  repository = "https://helm.pingidentity.com/"
  chart      = "ping-devops"
  namespace  = var.namespace

  values = [
    templatefile("paz.yaml.tpl", {
      externalUrl = var.externalUrl,
      oidcWellKnownEndpoint = var.oidcWellKnownEndpoint,
      clientId = var.clientId,
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