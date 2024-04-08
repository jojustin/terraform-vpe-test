##############################################################################
# Outputs
##############################################################################
# output "configjson" {
#   value   = local.configjson
# }

# output "crk_id" {
#   value   = local.kms_config.crk_id
# }

# output "test" {
#     value = ibm_is_virtual_endpoint_gateway.endpoint_gateways.target
# }


output "smcreated" {
    value = ibm_sm_arbitrary_secret.sm_arbitrary_secret_difftf.crn
}


# output "afer" {
#     value = ibm_sm_arbitrary_secret.sm_arbitrary_secret_after.crn
# }

##############################################################################
