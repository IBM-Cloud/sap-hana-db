module "vpc-subnet" {
  source		= "./modules/vpc/subnet"
  ZONE			= var.ZONE
  VPC			= var.VPC
  SECURITY_GROUP = var.SECURITY_GROUP
  SUBNET		= var.SUBNET
}

module "vsi" {
  source		= "./modules/vsi"
  ZONE			= var.ZONE
  VPC			= var.VPC
  SECURITY_GROUP = var.SECURITY_GROUP
  RESOURCE_GROUP = var.RESOURCE_GROUP
  SUBNET		= var.SUBNET
  HOSTNAME		= var.HOSTNAME
  PROFILE		= var.PROFILE
  IMAGE			= var.IMAGE
  SSH_KEYS		= var.SSH_KEYS
}

module "ansible-exec" {
  source		= "./modules/ansible-exec"
  depends_on	= [ module.vsi, local_file.ansible_saphana-vars, local_file.tf_ansible_hana_storage_generated_file]
  IP			= module.vsi.PRIVATE-IP
  PLAYBOOK_PATH = "ansible/saphana.yml"
}


module "sec-exec" {
  source		= "./modules/sec-exec"
  depends_on	= [ module.ansible-exec ]
  IP			= module.vsi.PRIVATE-IP
  hana_main_password = var.hana_main_password
}
