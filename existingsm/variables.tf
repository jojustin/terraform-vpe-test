##############################################################################
# Input Variables
##############################################################################
variable "ibmcloud_api_key" {
  type        = string
  description = "APIkey that's associated with the account to use for infrastructure setup, set via environment variable TF_VAR_ibmcloud_api_key or .tfvars file."
  sensitive   = true
}


variable "resource_group" {
  type        = string
  description = "Resource group ID where infra would be setup.  This RG should pre-exist"
  default = "jejschematics"
}

variable "region" {
  type        = string
  description = "Region where resources will be created or fetched from"
  default = "us-south"
}


variable "smguid" {
  type        = string
  description = "smguid"
  default = ""
}