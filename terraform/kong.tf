resource "helm_release" "kong" {
  name       = var.kongName
  chart      = "kong"
  repository = "https://charts.konghq.com"
  namespace  = var.namespace

  timeout = 90

  values = [
    "${file("kong.yaml")}"
  ]
  depends_on = [kubernetes_config_map.kong_declarative_config]
}

resource "kubernetes_config_map" "kong_declarative_config" {
  metadata {
    name      = "kong-declarative-config"
    namespace = var.namespace
  }
  # P1AZ Values
  data = {
    "kong.yml" = templatefile("./kong-declarative.yaml.tpl", {
      pluginSharedSecret = pingone_gateway_credential.kong_api_gateway.credential,
      serviceUrl         = "https://http-access-api.pingone.${local.pingone_domain}/v1/environments/${pingone_environment.kong_token_provider.id}"
    })
  }

  # PAZ \ PAP Values
  # data = {
  #   "kong.yml" = templatefile("./kong-declarative.yaml.tpl", {
  #     pluginSharedSecret = var.pluginSecret,
  #     serviceUrl = "https://${var.deployName}-pingauthorize"
  #   })
  # }
}

resource "kubernetes_ingress_v1" "kong_ingress" {
  metadata {
    namespace = var.namespace
    name      = "${var.kongName}-kong-proxy"
    annotations = {
      "kubernetes.io/ingress.class"                    = "nginx-public"
      "nginx.ingress.kubernetes.io/backend-protocol"   = "HTTPS"
      "nginx.ingress.kubernetes.io/cors-allow-headers" = "X-Forwarded-For"
      "nginx.ingress.kubernetes.io/force-ssl-redirect" = true
      "nginx.ingress.kubernetes.io/service-upstream"   = true
    }
  }

  spec {
    rule {
      host = "${var.kongName}.${var.deployDomain}"
      http {
        path {
          path = "/"
          backend {
            service {
              name = "${var.kongName}-kong-proxy"
              port {
                number = 443
              }
            }
          }
        }
      }
    }

    tls {
      hosts = ["${var.kongName}.${var.deployDomain}"]
    }
  }
}