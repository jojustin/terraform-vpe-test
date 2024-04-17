
data ibm_resource_group "resource_group" {
    name = var.resource_group
}

locals {
  prefix = "jej-17apr-rest"
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

resource "time_sleep" "wait_120_seconds" {
  depends_on      = [ibm_resource_instance.kms]
  create_duration = "120s"
}

#Create VPE
resource "restapi_object" "vpe_create" {
  depends_on = [ time_sleep.wait_120_seconds ]
  # should be ideally replaced with var.region
  path = "//au-syd.iaas.cloud.ibm.com/v1/endpoint_gateways?version=2024-04-16&generation=2&maturity=beta"
  data = "{\"name\": \"jejrestapi-tf-vpe-gateway\", \"target\": {\"crn\": \"crn:v1:bluemix:public:kms:au-syd:::endpoint:private.au-syd.kms.cloud.ibm.com\", \"resource_type\" : \"provider_cloud_service\"}, \"vpc\": {\"crn\": \"${ibm_is_vpc.vpc1.crn}\"}, \"resource_group\": {\"id\": \"${data.ibm_resource_group.resource_group.id}\"} }"
  create_method  = "POST"
  # create_path    = "//au-syd.iaas.cloud.ibm.com/v1/endpoint_gateways?version=2024-04-16&generation=2&maturity=beta"

}

resource "ibm_kms_key" "key_after" {
  depends_on = [ restapi_object.vpe_create ]
  instance_id   = ibm_resource_instance.kms.guid
  key_name      = "${var.service_endpoints}-after-key"
  key_ring_id   = "default"
  standard_key  = false
  endpoint_type = "private"
  force_delete  = "false"
}

