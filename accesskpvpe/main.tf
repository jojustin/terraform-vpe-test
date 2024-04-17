
data ibm_resource_group "resource_group" {
    name = var.resource_group
}

locals {
  prefix = "jej-17apr-kp"
  allowed_network = var.service_endpoints == "private" ? "private-only" : "public-and-private"
}

resource "ibm_is_vpc" "vpc1" {
  name = "${local.prefix}-vpc"
  default_security_group_name = "${local.prefix}-default-sg"
  resource_group = data.ibm_resource_group.resource_group.id
}

resource "ibm_is_subnet" "subnet1" {
  name                     = "${local.prefix}-subnet"
  vpc                      = ibm_is_vpc.vpc1.id
  zone                     = "${var.region}-1"
  total_ipv4_address_count = 256
  resource_group = data.ibm_resource_group.resource_group.id
}

##############################################################################
## Create prerequisite.  Secrets Manager,  Secret Group and a Trusted Profile
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

resource "ibm_kms_key" "key_before" {
  instance_id   = ibm_resource_instance.kms.guid
  key_name      = "${var.service_endpoints}-before-key"
  key_ring_id   = "default"
  standard_key  = false
  endpoint_type = "private"
  force_delete  = "false"
}

##############################################################################
# Virtual Endpoint Gateways
##############################################################################

resource "ibm_is_virtual_endpoint_gateway" "endpoint_gateways" {
  depends_on      = [ibm_is_subnet.subnet1, ibm_resource_instance.kms]
  name            = "${local.prefix}-vpe"
  # check if target is a CRN and handle accordingly
  target {
    crn = ibm_resource_instance.kms.crn
    resource_type = "provider_cloud_service"
  }
  vpc = ibm_is_vpc.vpc1.id
  security_groups = [ibm_is_vpc.vpc1.default_security_group]
  resource_group = data.ibm_resource_group.resource_group.id

}

resource "ibm_kms_key" "key_after" {
  instance_id   = ibm_resource_instance.kms.guid
  key_name      = "${var.service_endpoints}-after-key"
  key_ring_id   = "default"
  standard_key  = false
  endpoint_type = "private"
  force_delete  = "false"
}
