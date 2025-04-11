provider "kubernetes" {
  config_path = "~/.kube/config"
}

provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}

resource "helm_release" "kong-test" {
  name       = "kong-test"
  chart      = "kong"
  repository = "https://charts.konghq.com"
  namespace  = "ping-devops-cprice"

  values = [
    "${file("kong.yaml")}"
  ]
}

resource "helm_release" "test-paz" {
  name       = "paz-test"
  repository = "https://helm.pingidentity.com/"
  chart      = "ping-devops"
  namespace  = "ping-devops-cprice"

  values = [
    "${file("paz.yaml")}"
  ]
}

resource "kubernetes_config_map" "kong_plugin_ping_auth_config" {
  metadata {
    name = "kong-plugin-ping-auth-config"
  }

  data = {
    "access.lua" = <<-EOT
      local ngx = ngx
      local kong = kong
      local core = require "kong.core"
      local http = require "resty.http"
      local json = require "cjson"
      local utils = require "kong.plugins.ping-auth.utils"
      local constants = require "kong.plugins.ping-auth.constants"
      local schema = require "kong.plugins.ping-auth.schema"

      local PingAuthHandler = {
          PRIORITY = 200,
          VERSION = "1.0.0",
      }

      function PingAuthHandler:access(conf)
          kong.log.debug("ping-auth: access()")

          local request_headers = ngx.req.get_headers()
          local authorization = request_headers["authorization"]

          if not authorization then
              kong.log.err("ping-auth: Authorization header is missing")
              return ngx.exit(401)
          end

          local token = utils.extract_token(authorization)
          if not token then
              kong.log.err("ping-auth: Invalid Authorization header format")
              return ngx.exit(401)
          end

          local httpc = http.new()
          httpc:set_timeout(conf.timeout, conf.timeout, conf.timeout)

          local headers = {
              ["Authorization"] = "Bearer " .. token,
              ["Content-Type"] = "application/json",
          }

          local body = {
              client_id = conf.client_id,
              client_secret = conf.client_secret,
          }

          local res, err = httpc:request {
              url = conf.introspection_endpoint,
              method = "POST",
              headers = headers,
              body = json.encode(body),
          }

          if err then
              kong.log.err("ping-auth: Introspection request failed: ", err)
              return ngx.exit(500)
          end

          if res.status ~= 200 then
              kong.log.err("ping-auth: Introspection failed with status: ", res.status)
              return ngx.exit(401)
          end

          local introspection_response, err = json.decode(res.body)
          if err then
              kong.log.err("ping-auth: Failed to decode introspection response: ", err)
              return ngx.exit(500)
          end

          if not introspection_response.active then
              kong.log.err("ping-auth: Token is not active")
              return ngx.exit(401)
          end

          -- Add claims to request headers
          for claim_name, claim_value in pairs(introspection_response) do
              if claim_name ~= "active" then
                  ngx.req.set_header("X-Ping-" .. claim_name, claim_value)
              end
          end

          kong.log.debug("ping-auth: Token introspection successful")
      end

      return PingAuthHandler
    EOT
    "constants.lua" = <<-EOT
      local constants = {
          PLUGIN_NAME = "ping-auth",
          DEFAULT_TIMEOUT = 10000, -- 10 seconds
      }

      return constants
    EOT
    "handler.lua" = <<-EOT
      local PingAuthHandler = {
          PRIORITY = 200,
          VERSION = "1.0.0",
      }

      PingAuthHandler.access = require "kong.plugins.ping-auth.access".access

      return PingAuthHandler
    EOT
    "schema.lua" = <<-EOT
      local typedefs = {
          client_id = { type = "string", required = true },
          client_secret = { type = "string", required = true },
          introspection_endpoint = { type = "string", required = true },
          timeout = { type = "integer", default = require("kong.plugins.ping-auth.constants").DEFAULT_TIMEOUT },
      }

      local schema = {
          fields = typedefs,
      }

      return schema
    EOT
    "utils.lua" = <<-EOT
      local utils = {}

      function utils.extract_token(authorization)
          if not authorization then
              return nil
          end

          local token = string.match(authorization, "Bearer%s(.+)")
          return token
      end

      return utils
    EOT
  }
}

resource "kubernetes_config_map" "kong_declarative_config" {
  metadata {
    name = "kong-test-declarative"
  }

  data = {
    "kong.yml" = <<-EOT
      _format_version: "3.0"
      _transform: true

      services:
        - name: pingone-apis-facile
          url: https://api.pingone.com/v1/environments/5616de37-1dd8-404d-b9b6-b8cc2361600c
          routes:
            - name: pingone-apis
              paths:
                - /pingone/
              strip_path: true
    EOT
  }
}