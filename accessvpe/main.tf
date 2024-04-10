
data ibm_resource_group "resource_group" {
    name = var.resource_group
}

locals {
  prefix = "jej-10apr"
  allowed_network = var.service_endpoints == "private" ? "private-only" : "public-and-private"
}

##############################################################################
## Create secrets
##############################################################################

resource "ibm_sm_arbitrary_secret" "sm_arbitrary_secret_after" {
  name          = "fromanothertf-private-secret"
  instance_id   = "a29e22b9-5fe0-47a2-961a-0fd89e3bc007"
  region        = var.region
  custom_metadata = {"key":"privateaccess"}
  description = "Created by accessing the sm"
  labels = ["privateaccess"]
  payload = "secret-credentials"
  endpoint_type = "private"
}