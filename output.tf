output "HOSTNAME" {
  value		= module.vsi.HOSTNAME
}

output "PRIVATE_IP" {
  value		= module.vsi.PRIVATE-IP
}

output "VPC" {
  value		= var.VPC
}

output "STORAGE_LAYOUT" {
  value = module.vsi.STORAGE-LAYOUT
}
