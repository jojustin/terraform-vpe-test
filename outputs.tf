##############################################################################
# Outputs
##############################################################################
# output "configjson" {
#   value   = local.configjson
# }

# output "crk_id" {
#   value   = local.kms_config.crk_id
# }

output "smguid" {
    value = ibm_resource_instance.secrets_manager.guid
}


output "before" {
    value = ibm_sm_arbitrary_secret.sm_arbitrary_secret_before.crn
}


# output "afer" {
#     value = ibm_sm_arbitrary_secret.sm_arbitrary_secret_after.crn
# }

##############################################################################
