
data ibm_resource_group "resource_group" {
    name = var.resource_group
}

locals {
  prefix = "jej-12apr"
  allowed_network = var.service_endpoints == "private" ? "private-only" : "public-and-private"
}

##############################################################################
## Create secrets
##############################################################################

resource "ibm_resource_instance" "secrets_manager" {
  name              = "${local.prefix}-sm-private"
  service           = "secrets-manager"
  plan              = "trial"
  location          = var.region
  resource_group_id = data.ibm_resource_group.resource_group.id
  service_endpoints = var.service_endpoints
  timeouts {
    create = "20m" # Extending provisioning time to 20 minutes
  }
  parameters = {
    "allowed_network" = local.allowed_network
  }
}

# VPE provisioning should wait for the database provisioning
resource "time_sleep" "wait_120_seconds" {
  depends_on      = [ibm_resource_instance.secrets_manager]
  create_duration = "120s"
}

resource "ibm_sm_arbitrary_secret" "sm_arbitrary_secret_after" {
  name          = "after-vpe-secret"
  instance_id   = ibm_resource_instance.secrets_manager.guid
  region        = var.region
  custom_metadata = {"key":"beforevalue"}
  description = "Created after attaching VPE"
  labels = ["after-vpe"]
  payload = "secret-credentials"
  endpoint_type = "private"
}

# resource "ibm_sm_arbitrary_secret" "sm_arbitrary_secret_diff_public" {
#   name          = "fromanothertf-public-secret"
#   instance_id   = "a29e22b9-5fe0-47a2-961a-0fd89e3bc007"
#   region        = var.region
#   custom_metadata = {"key":"fromanothertf"}
#   description = "Created from another TF"
#   labels = ["fromanothertf-vpe"]
#   payload = "secret-credentials"
# }
