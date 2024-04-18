##############################################################################
# Outputs
##############################################################################
# output "subnetid" {
#   value   = data.ibm_is_subnet.subnet.id
# }

# output "subnetname" {
#   value   = data.ibm_is_subnet.subnet.name
# }

# output "vpeid" {
#   value   = data.ibm_is_virtual_endpoint_gateway.vpegateway.id
# }

# output "vpename" {
#   value   = data.ibm_is_virtual_endpoint_gateway.vpegateway.name
# }


output "reservedip" {
  value   = ibm_is_subnet_reserved_ip.reservedip.id
}


# output "crk_id" {
#   value   = local.kms_config.crk_id
# }

# output "test" {
#     value = ibm_is_virtual_endpoint_gateway.endpoint_gateways.target
# }


# output "smcreated" {
#     value = ibm_sm_arbitrary_secret.sm_arbitrary_secret_difftf.crn
# }


# output "afer" {
#     value = ibm_sm_arbitrary_secret.sm_arbitrary_secret_after.crn
# }

##############################################################################
