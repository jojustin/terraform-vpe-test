##############################################################################
# Outputs
##############################################################################
output "resourcegroupid" {
  value   = data.ibm_resource_group.resource_group.id
}

output "vpcid" {
  value   = ibm_is_vpc.vpc1.crn
}

output "kmscrn" {
    value = ibm_resource_instance.kms.crn
}


##############################################################################
