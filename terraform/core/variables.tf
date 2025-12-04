variable "location" {
  description = "Azure region"
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

variable "environment" {
  description = "Environment (e.g., dev, prod)"
  type        = string
}

variable "group" {
  description = "Group or project name"
  type        = string
}

variable "short_location" {
  description = "Short location identifier"
  type        = string
}

variable "node_count" {
  description = "Number of AKS nodes"
  type        = number
  default     = 3
}

variable "vm_size" {
  description = "VM size for AKS nodes"
  type        = string
  default     = "Standard_DS2_v2"
}

variable "authorized_ip_ranges" {
  description = "Authorized IP ranges for API server (CIS 5.4.1)"
  type        = list(string)
  default     = []
}

variable "admin_group_object_ids" {
  description = "Azure AD group IDs for AKS admins"
  type        = list(string)
  default     = []
}

variable "slack_webhook_url" {
  description = "Slack Webhook URL"
  type        = string
  sensitive   = true
  default     = ""
}

variable "log_retention_days" {
  description = "Log retention days"
  type        = number
  default     = 90
}
