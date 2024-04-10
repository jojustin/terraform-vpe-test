
data ibm_resource_group "resource_group" {
    name = var.resource_group
}

locals {
  prefix = "jej-10apr"
}

##############################################################################
## Create secrets
##############################################################################

resource "ibm_sm_arbitrary_secret" "sm_arbitrary_secret_after" {
  name          = "fromanothertf-private-secret"
  instance_id   = var.smguid
  region        = var.region
  custom_metadata = {"key":"privateaccess"}
  description = "Created by accessing sm"
  labels = ["privateaccess"]
  payload = "secret-credentials"
}

