# modules/shared_configmap/main.tf

resource "kubernetes_config_map" "kong_plugin_ping_auth_config" {
  metadata {
    name = "kong-plugin-ping-auth-config"
    namespace = var.namespace
  }

  data = {
    "access.lua" = var.access_lua
    "constants.lua" = var.constants_lua
    "handler.lua" = var.handler_lua
    "schema.lua" = var.schema_lua
    "utils.lua" = var.utils_lua
  }
}

variable "access_lua" {
  type = string
}

variable "constants_lua" {
  type = string
}

variable "handler_lua" {
  type = string
}

variable "schema_lua" {
  type = string
}

variable "utils_lua" {
  type = string
}

variable "namespace" {
  type = string
}

output "configmap_name" {
  value = kubernetes_config_map.kong_plugin_ping_auth_config.metadata[0].name
}