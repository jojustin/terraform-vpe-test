
data ibm_resource_group "resource_group" {
    name = var.resource_group
}

locals {
  prefix = "jej-12apr"
  # allowed_network = var.service_endpoints == "private" ? "private-only" : "public-and-private"
}

##############################################################################
## Create prerequisite.  Secrets Manager,  Secret Group and a Trusted Profile
##############################################################################

resource "ibm_resource_instance" "secrets_manager" {
  name              = "${local.prefix}-sm"
  service           = "secrets-manager"
  plan              = "trial"
  location          = var.region
  resource_group_id = data.ibm_resource_group.resource_group.id
  # service_endpoints = var.service_endpoints
  timeouts {
    create = "20m" # Extending provisioning time to 20 minutes
  }
  # parameters = {
  #   "allowed_network" = allowed_network
  # }
}

# VPE provisioning should wait for the database provisioning
resource "time_sleep" "wait_120_seconds" {
  depends_on      = [ibm_resource_instance.secrets_manager]
  create_duration = "120s"
}

resource "ibm_sm_arbitrary_secret" "sm_arbitrary_secret_before" {
  name          = "visibility-private-secret"
  instance_id   = ibm_resource_instance.secrets_manager.guid
  region        = var.region
  custom_metadata = {"key":"visibilityprivate"}
  description = "Created with visibility private"
  labels = ["visibility-private-secret"]
  payload = "secret-credentials"
  # endpoint_type = "private"
}

