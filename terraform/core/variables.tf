variable "location" {
  description = "The Azure region where resources will be deployed"
  type        = string
  default     = "southeastasia"
}

variable "subscription_id" {
  description = "Azure Subscription ID"
  type        = string
}

variable "tenant_id" {
  description = "Azure Tenant ID"
  type        = string
}
