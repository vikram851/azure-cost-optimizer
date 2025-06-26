provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "main" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_storage_account" "archive" {
  name                     = var.storage_account_name
  resource_group_name      = azurerm_resource_group.main.name
  location                 = azurerm_resource_group.main.location
  account_tier             = "Standard"
  account_replication_type = "GRS"
  access_tier              = "Cool"
 
}

resource "azurerm_storage_container" "archive_container" {
  name                  = "billing-archive"
  storage_account_name  = azurerm_storage_account.archive.name
  container_access_type = "private"
}

resource "azurerm_cosmosdb_account" "cosmos" {
  name                = var.cosmos_account_name
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  offer_type          = "Standard"
  kind                = "GlobalDocumentDB"
  consistency_policy {
    consistency_level = "Session"
  }
  geo_location {
    location          = azurerm_resource_group.main.location
    failover_priority = 0
  }
}

resource "azurerm_cosmosdb_sql_database" "db" {
  name                = var.cosmos_db_name
  resource_group_name = azurerm_resource_group.main.name
  account_name        = azurerm_cosmosdb_account.cosmos.name
}

resource "azurerm_cosmosdb_sql_container" "container" {
  name                  = var.cosmos_container_name
  resource_group_name   = azurerm_resource_group.main.name
  account_name          = azurerm_cosmosdb_account.cosmos.name
  database_name         = azurerm_cosmosdb_sql_database.db.name
  partition_key_path    = "/partitionKey"
  throughput            = 400
}

resource "azurerm_service_plan" "plan" {
  name                = "billing-consumption-plan"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  os_type             = "Linux"
  sku_name            = "Y1"
}

resource "azurerm_linux_function_app" "function" {
  name                = var.function_app_name
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  service_plan_id     = azurerm_service_plan.plan.id
  storage_account_name       = azurerm_storage_account.archive.name
  storage_account_access_key = azurerm_storage_account.archive.primary_access_key
  site_config {
    application_stack {
      python_version = "3.11"
    }
  }

  app_settings = {
    "AzureWebJobsStorage"     = azurerm_storage_account.archive.primary_connection_string
    "COSMOS_URI"              = azurerm_cosmosdb_account.cosmos.endpoint
    "COSMOS_KEY"              = azurerm_cosmosdb_account.cosmos.primary_key
    "COSMOS_DB"               = azurerm_cosmosdb_sql_database.db.name
    "COSMOS_CONTAINER"        = azurerm_cosmosdb_sql_container.container.name
    "BLOB_CONN_STR"           = azurerm_storage_account.archive.primary_connection_string
    "BLOB_CONTAINER"          = azurerm_storage_container.archive_container.name
  }
}
