
data ibm_resource_group "resource_group" {
    name = var.resource_group
}

locals {
  prefix = "jej-17apr-schematics-kp"
  allowed_network = var.service_endpoints == "private" ? "private-only" : "public-and-private"
}

##############################################################################
## Create secrets
##############################################################################

resource "ibm_resource_instance" "kms" {
  name              = "${local.prefix}-private"
  service           = "kms"
  plan              = "tiered-pricing"
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
  depends_on      = [ibm_resource_instance.kms]
  create_duration = "120s"
}

resource "ibm_kms_key" "key" {
  instance_id   = ibm_resource_instance.kms.guid
  key_name      = "${var.service_endpoints}-key"
  key_ring_id   = "default"
  standard_key  = false
  #endpoint_type = "private"
  force_delete  = "false"
}
