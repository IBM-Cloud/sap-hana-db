output "HOSTNAME" {
  value		= module.vsi.HOSTNAME
}

output "PRIVATE-IP" {
  value		= module.vsi.PRIVATE-IP
}

output "VPC" {
  value		= var.VPC
}

output "STORAGE-LAYOUT" {
  value = module.vsi.STORAGE-LAYOUT
}
