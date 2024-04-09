
data ibm_resource_group "resource_group" {
    name = var.resource_group
}

locals {
  prefix = "jej-8apr"
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

resource "ibm_container_vpc_cluster" "cluster" {
  name              = "${local.prefix}-vpc-cluster"
  vpc_id            = ibm_is_vpc.vpc1.id
  flavor            = "bx2.2x8"
  worker_count      = "2"
  resource_group_id = data.ibm_resource_group.resource_group.id
  # cos_instance_crn  = module.cos_instance.cos_instance_id
  zones {
      subnet_id = ibm_is_subnet.subnet1.id
      name      = "${var.region}-1"
    }
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
  service_endpoints = "private"
  timeouts {
    create = "20m" # Extending provisioning time to 20 minutes
  }
  parameters = {
   private_endpoint_type: "vpe"
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
}

##############################################################################
# VPE
##############################################################################

# module "vpe" {
#   source  = "terraform-ibm-modules/vpe-gateway/ibm"
#   version = "4.1.1"
#   prefix  = "vpe-to-sm"
#   cloud_service_by_crn = [
#     {
#       service_name = "${local.prefix}-sm"
#       crn          = ibm_resource_instance.secrets_manager.crn
#     },
#   ]
#   vpc_id             = ibm_is_vpc.vpc1.id
#   subnet_zone_list   = ibm_is_vpc.vpc1.subnets
#   resource_group_id  = data.ibm_resource_group.resource_group.id
#   security_group_ids = [ibm_is_vpc.vpc1.default_security_group]
#   depends_on = [
#     time_sleep.wait_120_seconds
#   ]
# }

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
}