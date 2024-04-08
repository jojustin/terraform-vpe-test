
data ibm_resource_group "resource_group" {
    name = var.resource_group
}

locals {
  prefix = "jej-8apr"
}

##############################################################################
## Create secrets
##############################################################################

resource "ibm_sm_arbitrary_secret" "sm_arbitrary_secret_difftf" {
  name          = "fromanothertf-vpe-secret"
  instance_id   = var.smguid
  region        = var.region
  custom_metadata = {"key":"fromanothertf"}
  description = "Created from another TF"
  labels = ["fromanothertf-vpe"]
  payload = "secret-credentials"
}