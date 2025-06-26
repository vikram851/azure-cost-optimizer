output "function_app_url" {
  value = azurerm_linux_function_app.function.default_hostname
}

output "cosmosdb_uri" {
  value = azurerm_cosmosdb_account.cosmos.endpoint
}

output "storage_account_name" {
  value = azurerm_storage_account.archive.name
}