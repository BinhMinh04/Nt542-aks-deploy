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

variable "environment" {
  description = "The environment for the deployment (e.g., dev, prod)"
  type        = string
}

variable "group" {
  description = "The group or project name"
  type        = string
}

variable "short_location" {
  description = "A short identifier for the location"
  type        = string
}

variable "node_count" {
  description = "Number of nodes in the AKS cluster"
  type        = number
  default     = 3
}

variable "vm_size" {
  description = "The size of the VM for the AKS nodes"
  type        = string
  default     = "Standard_DS2_v2"
}

variable "authorized_ip_ranges" {
  description = "List of authorized IP ranges for API server access"
  type        = list(string)
  default     = ["10.0.0.0/8"]  # Allow all IPs - restrict this in production
}

variable "admin_group_object_ids" {
  description = "List of Azure AD group object IDs for AKS cluster administrators"
  type        = list(string)
  default     = []
}

variable "slack_webhook_url" {
  description = "Slack Webhook URL"
  type        = string
  sensitive   = true
  default     = ""
}