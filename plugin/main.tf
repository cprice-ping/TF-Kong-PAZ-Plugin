module "shared_configmap" {
  source              = "../modules/shared_configmap"
  access_lua          = file("../ping-auth/access.lua")
  network_handler_lua = file("../ping-auth/network_handler.lua")
  handler_lua         = file("../ping-auth/handler.lua")
  schema_lua          = file("../ping-auth/schema.lua")
  response_lua        = file("../ping-auth/response.lua")
  namespace           = var.namespace
}