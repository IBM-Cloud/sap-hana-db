module "vpc-subnet" {
  source		= "./modules/vpc/subnet"
  ZONE			= var.ZONE
  VPC			= var.VPC
  SECURITY_GROUP = var.SECURITY_GROUP
  SUBNET		= var.SUBNET
}

module "volumes" {
  source		= "./modules/volumes"
  ZONE			= var.ZONE
  HOSTNAME		= var.HOSTNAME
  RESOURCE_GROUP = var.RESOURCE_GROUP
  VOL_PROFILE	= "custom"
  VOL_IOPS		= "10000"
  VOL1			= var.VOL1
  VOL2			= var.VOL2
  VOL3			= var.VOL3
}

module "vsi" {
  source		= "./modules/vsi"
  depends_on	= [ module.volumes ]
  ZONE			= var.ZONE
  VPC			= var.VPC
  SECURITY_GROUP = var.SECURITY_GROUP
  RESOURCE_GROUP = var.RESOURCE_GROUP
  SUBNET		= var.SUBNET
  HOSTNAME		= var.HOSTNAME
  PROFILE		= var.PROFILE
  IMAGE			= var.IMAGE
  SSH_KEYS		= var.SSH_KEYS
  VOLUMES_LIST	= module.volumes.volumes_list
}

module "ansible-exec" {
  source		= "./modules/ansible-exec"
  depends_on	= [ module.vsi ]
  IP			= module.vsi.PRIVATE-IP
  hana_master_password = var.hana_master_password
}
