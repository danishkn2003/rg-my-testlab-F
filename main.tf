terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
  backend "azurerm" {
    resource_group_name  = "rg-my-testlab-F"
    storage_account_name = "pocterraformstate635287"
    container_name       = "tfstate"
    key                  = "terraform.tfstate"
  }
}

provider "azurerm" {
  features {}
}

# Use data source to read existing RG
data "azurerm_resource_group" "poc" {
  name = "rg-my-testlab-F"
}

# Create storage account inside that RG
resource "azurerm_storage_account" "poc" {
  name                     = "pocterraformappsa5217"
  resource_group_name      = data.azurerm_resource_group.poc.name
  location                 = data.azurerm_resource_group.poc.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}