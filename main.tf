terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
  backend "azurerm" {
    resource_group_name  = "rg-my-testlab-F"
    storage_account_name = "pocterraformstate"
    container_name       = "tfstate"
    key                  = "terraform.tfstate"
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "poc" {
  name     = "rg-my-testlab-F"
  location = var.location
}

resource "azurerm_storage_account" "poc" {
  name                     = "pocterraformappsa"
  resource_group_name      = azurerm_resource_group.poc.name
  location                 = azurerm_resource_group.poc.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}