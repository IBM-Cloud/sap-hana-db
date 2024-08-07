output "DB_HOSTNAME" {
  value		= lower(trimspace(var.HANA_SERVER_TYPE)) == "virtual" ? data.ibm_is_instance.db-vsi[0].name : data.ibm_is_bare_metal_server.db-bms[0].name 
}

output "DB_PRIVATE_IP" {
  value		= lower(trimspace(var.HANA_SERVER_TYPE)) == "virtual" ? data.ibm_is_instance.db-vsi[0].primary_network_interface[0].primary_ip[0].address : data.ibm_is_bare_metal_server.db-bms[0].primary_network_interface[0].primary_ip[0].address
}

output "HANA_SID" {
  value		= var.HANA_SID
}

output "VPC" {
  value		= var.VPC
}

output "SUBNET" {
  value		= var.SUBNET
}

output "SECURITY_GROUP" {
  value		= var.SECURITY_GROUP
}

output "STORAGE_LAYOUT" {
  value = lower(trimspace(var.HANA_SERVER_TYPE)) == "virtual" ? module.db-vsi[0].STORAGE-LAYOUT : module.db-bms[0].STORAGE-LAYOUT
}

