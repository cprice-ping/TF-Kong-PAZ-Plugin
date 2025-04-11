module "shared_configmap" {
  source        = "./modules/shared_configmap"
  access_lua    = file("ping-auth/access.lua")
  constants_lua = file("ping-auth/constants.lua")
  handler_lua   = file("ping-auth/handler.lua")
  schema_lua    = file("ping-auth/schema.lua")
  utils_lua     = file("ping-auth/utils.lua")
  namespace     = var.namespace
}