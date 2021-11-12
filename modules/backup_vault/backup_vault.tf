locals {
  # Need to update the storage tags if the environment tag is updated with the rover command line
  tags = lookup(var.storage_account, "tags", null) == null ? null : lookup(var.storage_account.tags, "environment", null) == null ? var.storage_account.tags : merge(lookup(var.storage_account, "tags", {}), { "environment" : var.global_settings.environment })
}

# naming convention
# resource "azurecaf_name" "backup_vault_name" {
#   name          = var.settings.name
#   resource_type = "azurerm_data_protection_backup_vault"
#   prefixes      = var.global_settings.prefixes
#   random_length = var.global_settings.random_length
#   clean_input   = true
#   passthrough   = var.global_settings.passthrough
#   use_slug      = var.global_settings.use_slug
# }

resource "random_string" "bckp_name" {
  count   = try(var.global_settings.prefix, null) == null ? 1 : 0
  length  = 4
  special = false
  upper   = false
  number  = true
}

resource "azurerm_data_protection_backup_vault" "backup_vault" {
  name                = random_string.bckp_name  #azurecaf_name.backup_vault_name.result
  location            = var.location
  resource_group_name = var.resource_group_name
  datastore_type      = try(var.settings.datastore_type, "VaultStore")
  redundancy          = try(var.settings.redundancy, "LocallyRedundant")
  tags                = merge(var.base_tags, local.tags)

  identity {
    type = "SystemAssigned"
  }
}
