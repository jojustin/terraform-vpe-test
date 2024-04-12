
data ibm_resource_group "resource_group" {
    name = var.resource_group
}

locals {
  prefix = "jej-12apr"
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

resource "ibm_resource_instance" "secrets_manager" {
  name              = "${local.prefix}-sm-vpe"
  service           = "secrets-manager"
  plan              = "trial"
  location          = var.region
  resource_group_id = data.ibm_resource_group.resource_group.id
  service_endpoints = var.service_endpoints
  timeouts {
    create = "20m" # Extending provisioning time to 20 minutes
  }
  parameters = {
    "allowed_network" = allowed_network
  }
}

# VPE provisioning should wait for the database provisioning
resource "time_sleep" "wait_120_seconds" {
  depends_on      = [ibm_resource_instance.secrets_manager]
  create_duration = "120s"
}

resource "ibm_sm_arbitrary_secret" "sm_arbitrary_secret_before" {
  name          = "before-vpe-secret"
  instance_id   = ibm_resource_instance.secrets_manager.guid
  region        = var.region
  custom_metadata = {"key":"beforevalue"}
  description = "Created before attaching VPE"
  labels = ["before-vpe"]
  payload = "secret-credentials"
  endpoint_type = "private"
}

##############################################################################
# Virtual Endpoint Gateways
##############################################################################

resource "ibm_is_virtual_endpoint_gateway" "endpoint_gateways" {
  depends_on      = [ibm_is_subnet.subnet1]
  name            = "${local.prefix}-vpe"
  # check if target is a CRN and handle accordingly
  target {
    crn = ibm_resource_instance.secrets_manager.crn
    resource_type = "provider_cloud_service"
  }
  vpc = ibm_is_vpc.vpc1.id
  security_groups = [ibm_is_vpc.vpc1.default_security_group]
  resource_group = data.ibm_resource_group.resource_group.id

}

resource "ibm_sm_arbitrary_secret" "sm_arbitrary_secret_after" {
  depends_on      = [ibm_is_virtual_endpoint_gateway.endpoint_gateways]
  name          = "after-vpe-secret"
  instance_id   = ibm_resource_instance.secrets_manager.guid
  region        = var.region
  custom_metadata = {"key":"aftervalue"}
  description = "Created after attaching VPE"
  labels = ["after-vpe"]
  payload = "secret-credentials"
  endpoint_type = "private"
}