
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
  instance_id   = "a29e22b9-5fe0-47a2-961a-0fd89e3bc007"
  region        = var.region
  custom_metadata = {"key":"fromanothertf"}
  description = "Created from another TF"
  labels = ["fromanothertf-vpe"]
  payload = "secret-credentials"
}

resource "ibm_sm_arbitrary_secret" "sm_arbitrary_secret_difftf" {
  name          = "fromanothertf-vpe-secret"
  instance_id   = "40cc23a8-d73d-4da3-ac3a-1fa75cf6678f"
  region        = var.region
  custom_metadata = {"key":"fromanothertf"}
  description = "Created from another TF"
  labels = ["fromanothertf-vpe"]
  payload = "secret-credentials"
}