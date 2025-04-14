resource "helm_release" "kong-test" {
  name       = "kong-test"
  chart      = "kong"
  repository = "https://charts.konghq.com"
  namespace  = var.namespace

  timeout = 90

  values = [
    "${file("kong.yaml")}"
  ]
}

resource "kubernetes_config_map" "kong_declarative_config" {
  metadata {
    name = "kong-declarative-config"
    namespace = var.namespace
  }
  data = {
    "kong.yml" = templatefile("./kong-declarative.yaml.tpl", {
      pluginSharedSecret = var.pluginSharedSecret,
      serviceUrl = data.kubernetes_service.paz_service.metadata.0.name
    })
  }
  depends_on = [data.kubernetes_service.paz_service]
}


