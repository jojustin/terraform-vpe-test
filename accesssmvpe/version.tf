terraform {
  required_version = ">= v1.0.0"
  required_providers {
    # Use "greater than or equal to" range in modules
    ibm = {
      source  = "IBM-Cloud/ibm"
      version = ">= 1.49.0"
    }
    null = {
      version = ">= 3.2.1"
    }
    external = {
      source = "hashicorp/external"
      version = "2.3.1"
    }
  }
}
