variable "location" {
  default = "eastus"
}

variable "resource_group_name" {
  default = "billing-archival-rg"
}

variable "storage_account_name" {
  default = "billingarchivestg"
}

variable "cosmos_account_name" {
  default = "billingcosmosacct"
}

variable "cosmos_db_name" {
  default = "billingdb"
}

variable "cosmos_container_name" {
  default = "records"
}

variable "function_app_name" {
  default = "billing-archival-fn"
}