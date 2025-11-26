provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rg" {
  name     = "rg-terraform-poc-f"
  location = "northeurope"
}

resource "azurerm_key_vault" "kv" {
  name                      = "kv-terraform-poc-f"
  location                  = azurerm_resource_group.rg.location
  resource_group_name       = azurerm_resource_group.rg.name
  tenant_id                 = var.tenant_id
  sku_name                  = "standard"
  enable_rbac_authorization = true
}

resource "azurerm_role_assignment" "kv_access" {
  principal_id         = var.client_object_id
  role_definition_name = "Key Vault Secrets Officer"
  scope                = azurerm_key_vault.kv.id
}

resource "random_password" "vm_admin_password" {
  length           = 20
  special          = true
  override_special = "_%@"
}

resource "azurerm_key_vault_secret" "vm_admin_password" {
  name         = "vm-admin-password"
  value        = random_password.vm_admin_password.result
  key_vault_id = azurerm_key_vault.kv.id
}

data "azurerm_key_vault_secret" "vm_password" {
  name         = azurerm_key_vault_secret.vm_admin_password.name
  key_vault_id = azurerm_key_vault.kv.id
}

# Networking
resource "azurerm_virtual_network" "vnet" {
  name                = "poc-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_subnet" "subnet" {
  name                 = "poc-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_network_interface" "nic" {
  name                = "poc-nic"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}
resource "azurerm_linux_virtual_machine" "vm" {
name                  = "pocvm01"
resource_group_name   = azurerm_resource_group.rg.name
location              = azurerm_resource_group.rg.location
size                  = "Standard_B2s"
admin_username        = "azureadmin"
admin_password        = data.azurerm_key_vault_secret.vm_password.value
network_interface_ids = [azurerm_network_interface.nic.id]
os_disk {
  name = "poc-vm-osdisk"
  caching = "ReadWrite"
  storage_account_type = "standard_lrs"
}
}