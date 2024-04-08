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
  default = "jejvpe"
}

variable "region" {
  type        = string
  description = "Region where resources will be created or fetched from"
  default = "us-east"
}


variable "smguid" {
  type        = string
  description = "SMGuid"
  default = "93091e65-22b8-44eb-8a0b-6e3fd592d0ea"
}