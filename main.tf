module "pre-init-schematics" {
  source = "./modules/pre-init"
  count = (var.PRIVATE_SSH_KEY == "n.a" && var.BASTION_FLOATING_IP == "localhost" ? 0 : 1)
  ID_RSA_FILE_PATH = var.ID_RSA_FILE_PATH
  PRIVATE_SSH_KEY = var.PRIVATE_SSH_KEY
}

module "pre-init-cli" {
  source = "./modules/pre-init/cli"
  count = (var.PRIVATE_SSH_KEY == "n.a" && var.BASTION_FLOATING_IP == "localhost" ? 1 : 0)
  ID_RSA_FILE_PATH = var.ID_RSA_FILE_PATH
  KIT_SAPHANA_FILE = var.KIT_SAPHANA_FILE
}

module "precheck-ssh-exec" {
  source = "./modules/precheck-ssh-exec"
  count = (var.PRIVATE_SSH_KEY == "n.a" && var.BASTION_FLOATING_IP == "localhost" ? 0 : 1)
  depends_on = [ module.pre-init-schematics ]
  BASTION_FLOATING_IP = var.BASTION_FLOATING_IP
  ID_RSA_FILE_PATH = var.ID_RSA_FILE_PATH
  PRIVATE_SSH_KEY = var.PRIVATE_SSH_KEY
  HOSTNAME = var.DB_HOSTNAME
  SECURITY_GROUP = var.SECURITY_GROUP
}

module "vpc-subnet" {
  source = "./modules/vpc/subnet"
  depends_on = [ module.precheck-ssh-exec ]
  ZONE = var.ZONE
  VPC = var.VPC
  SECURITY_GROUP = var.SECURITY_GROUP
  SUBNET = var.SUBNET
}

module "db-vsi" {
  source		= "./modules/db-vsi"
  depends_on	= [ module.precheck-ssh-exec ]
  ZONE			= var.ZONE
  VPC			= var.VPC
  SECURITY_GROUP = var.SECURITY_GROUP
  RESOURCE_GROUP = var.RESOURCE_GROUP
  SUBNET		= var.SUBNET
  HOSTNAME		= var.DB_HOSTNAME
  PROFILE		= var.DB_PROFILE
  IMAGE			= var.DB_IMAGE
  SSH_KEYS		= var.SSH_KEYS
  count = lower(trimspace(var.HANA_SERVER_TYPE)) == "virtual" ? 1 : 0
}

module "db-bms" {
  source		= "./modules/db-bms"
  depends_on	= [ module.precheck-ssh-exec ]
  ZONE			= var.ZONE
  VPC			= var.VPC
  SECURITY_GROUP = var.SECURITY_GROUP
  SUBNET		= var.SUBNET
  HOSTNAME		= var.DB_HOSTNAME
  PROFILE		= var.DB_PROFILE
  IMAGE			= var.DB_IMAGE
  RESOURCE_GROUP = var.RESOURCE_GROUP
  SSH_KEYS		= var.SSH_KEYS
  count = lower(trimspace(var.HANA_SERVER_TYPE)) != "virtual" ? 1 : 0
}

module "ansible-exec-schematics" {
  source  = "./modules/ansible-exec"
  depends_on = [ local_file.ansible_inventory, local_file.ansible_saphana-vars ]
  count = (var.PRIVATE_SSH_KEY == "n.a" && var.BASTION_FLOATING_IP == "localhost" ? 0 : 1)
  IP = lower(trimspace(var.HANA_SERVER_TYPE)) == "virtual" ? data.ibm_is_instance.db-vsi[0].primary_network_interface[0].primary_ip[0].address : data.ibm_is_bare_metal_server.db-bms[0].primary_network_interface[0].primary_ip[0].address
  PLAYBOOK = "saphana.yml"
  BASTION_FLOATING_IP = var.BASTION_FLOATING_IP
  ID_RSA_FILE_PATH = var.ID_RSA_FILE_PATH
  PRIVATE_SSH_KEY = var.PRIVATE_SSH_KEY
}

module "ansible-exec-cli" {
  source  = "./modules/ansible-exec/cli"
  depends_on = [ local_file.ansible_inventory, local_file.ansible_saphana-vars]
  count = (var.PRIVATE_SSH_KEY == "n.a" && var.BASTION_FLOATING_IP == "localhost" ? 1 : 0)
  ID_RSA_FILE_PATH = var.ID_RSA_FILE_PATH
  HANA_MAIN_PASSWORD = var.HANA_MAIN_PASSWORD
  IP = lower(trimspace(var.HANA_SERVER_TYPE)) == "virtual" ? data.ibm_is_instance.db-vsi[0].primary_network_interface[0].primary_ip[0].address : data.ibm_is_bare_metal_server.db-bms[0].primary_network_interface[0].primary_ip[0].address
  PLAYBOOK = "saphana.yml"
}
