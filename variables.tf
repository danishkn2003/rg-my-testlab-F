variable "resource_group_name" {
  type        = string
  default     = "rg-terraform-poc-f"
  description = "Name of the existing resource group"
}

variable "location" {
  type        = string
  default     = "northeurope"
  description = "Azure region for resources"
}
variable "tenant_id" {
  type        = string
  description = "Azure Active Directory tenant ID used for resource authentication"
}

variable "client_object_id" {
  type        = string
  description = "Object ID of the service principal or user to be granted access"
}