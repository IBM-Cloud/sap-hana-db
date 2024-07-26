##########################################################
# General & Default VPC variables for CLI deployment
##########################################################

variable "PRIVATE_SSH_KEY" {
	type		= string
	description = "id_rsa private key content in OpenSSH format (Sensitive* value). This private key should be used only during the terraform provisioning and it is recommended to be changed after the SAP deployment."
        nullable = false
        validation {
        condition = length(var.PRIVATE_SSH_KEY) >= 64 && var.PRIVATE_SSH_KEY != null && length(var.PRIVATE_SSH_KEY) != 0 || contains(["n.a"], var.PRIVATE_SSH_KEY )
        error_message = "The content for private_ssh_key variable must be completed in OpenSSH format."
     }
}

variable "ID_RSA_FILE_PATH" {
    default = "ansible/id_rsa"
    nullable = false
    description = "The file path for PRIVATE_SSH_KEY. It will be automatically generated. If it is changed, it must contain the relative path from git repo folders. Example: ansible/id_rsa_ase_hana"
}

variable "SSH_KEYS" {
	type		= list(string)
	description = "List of IBM Cloud SSH Keys UUIDs that are allowed to connect via SSH, as root, to the SAP HANA server. The SSH Keys should be created for the same region as the SAP HANA server. Can contain one or more IDs. Example: [\"r010-5db21872-c98f-4945-9f69-71c637b1da50\", \"r010-6dl21976-c97f-7935-8dd9-72c637g1ja31\"]. The list of SSH Keys is available here: https://cloud.ibm.com/vpc-ext/compute/sshKeys."
	validation {
		condition     = var.SSH_KEYS == [] ? false : true && var.SSH_KEYS == [""] ? false : true
		error_message = "At least one SSH KEY is needed to be able to access the SAP HANA Server."
	}
}

variable "BASTION_FLOATING_IP" {
        type            = string
        description = "The FLOATING IP of the Bastion Server"
        nullable = false
        validation {
        condition = can(regex("^(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$",var.BASTION_FLOATING_IP)) || contains(["localhost"], var.BASTION_FLOATING_IP ) && var.BASTION_FLOATING_IP!= null
        error_message = "Incorrect format for variable: BASTION_FLOATING_IP."
      }
}

variable "RESOURCE_GROUP" {
  type        = string
  description = "The name of an EXISTING Resource Group for SAP HANA Server and Volumes resources. The list of Resource Groups is available here: https://cloud.ibm.com/account/resource-groups."
  default     = "Default"
}

variable "REGION" {
	type		= string
	description	= "The cloud region where to deploy SAP HANA Server. The regions and zones for VPC are listed here:https://cloud.ibm.com/docs/containers?topic=containers-regions-and-zones#zones-vpc. The available regions and zones for VPC can be found here: https://cloud.ibm.com/docs/containers?topic=containers-regions-and-zones#zones-vpc. Supported locations for IBM Cloud Schematics here: https://cloud.ibm.com/docs/schematics?topic=schematics-locations."
	validation {
		condition     = contains(["au-syd", "jp-osa", "jp-tok", "eu-de", "eu-gb", "ca-tor", "us-south", "us-east", "br-sao"], var.REGION )
		error_message = "For CLI deployments, the REGION must be one of: au-syd, jp-osa, jp-tok, eu-de, eu-gb, ca-tor, us-south, us-east, br-sao. \n For Schematics, the REGION must be one of: eu-de, eu-gb, us-south, us-east."
	}
}

variable "ZONE" {
	type		= string
	description	= "The cloud zone where to deploy the SAP HANA Server. The available regions and zones for VPC can be found here: https://cloud.ibm.com/docs/containers?topic=containers-regions-and-zones#zones-vpc"
	validation {
		condition     = length(regexall("^(au-syd|jp-osa|jp-tok|eu-de|eu-gb|ca-tor|us-south|us-east|br-sao)-(1|2|3)$", var.ZONE)) > 0
		error_message = "The ZONE is not valid."
	}
}

variable "VPC" {
	type		= string
	description = "The name of an EXISTING VPC where to deploy the SAP HANA Server. The list of VPCs is available here: https://cloud.ibm.com/vpc-ext/network/vpcs."
	validation {
		condition     = length(regexall("^([a-z]|[a-z][-a-z0-9]*[a-z0-9]|[0-9][-a-z0-9]*([a-z]|[-a-z][-a-z0-9]*[a-z0-9]))$", var.VPC)) > 0
		error_message = "The VPC name is not valid."
	}
}

variable "SUBNET" {
	type		= string
	description = "The name of an EXISTING Subnet in the same VPC and same zone. The list of Subnets is available here: https://cloud.ibm.com/vpc-ext/network/subnets."
	validation {
		condition     = length(regexall("^([a-z]|[a-z][-a-z0-9]*[a-z0-9]|[0-9][-a-z0-9]*([a-z]|[-a-z][-a-z0-9]*[a-z0-9]))$", var.SUBNET)) > 0
		error_message = "The SUBNET name is not valid."
	}
}

variable "SECURITY_GROUP" {
	type		= string
	description = "The name of an EXISTING Security group for the same VPC. The list of Security Groups is available here: https://cloud.ibm.com/vpc-ext/network/securityGroups."
	validation {
		condition     = length(regexall("^([a-z]|[a-z][-a-z0-9]*[a-z0-9]|[0-9][-a-z0-9]*([a-z]|[-a-z][-a-z0-9]*[a-z0-9]))$", var.SECURITY_GROUP)) > 0
		error_message = "The SECURITY_GROUP name is not valid."
	}
}

variable "HANA_SERVER_TYPE" {
	type		= string
	description = "The type of SAP HANA Server. Allowed vales: \"virtual\" or \"bare metal\"."
	validation {
		condition = contains(["virtual", "bare metal"], var.HANA_SERVER_TYPE)
		error_message = "The type of SAP HANA server is not valid. The allowed values should be one of the following: \"virtual\" or \"bare metal\""
	}
}

variable "DB_HOSTNAME" {
	type		= string
	description = "The Hostname for SAP HANA Server. The hostname should be up to 13 characters as required by SAP. For more information on rules regarding hostnames for SAP systems, check SAP Note 611361: \"Hostnames of SAP ABAP Platform servers\"."
	validation {
		condition     = length(var.DB_HOSTNAME) <= 13 && length(regexall("^(([a-zA-Z0-9]|[a-zA-Z0-9][a-zA-Z0-9\\-]*[a-zA-Z0-9])\\.)*([A-Za-z0-9]|[A-Za-z0-9][A-Za-z0-9\\-]*[A-Za-z0-9])$", var.DB_HOSTNAME)) > 0
		error_message = "The DB_HOSTNAME is not valid."
	}
}

variable "DB_PROFILE" {
	type		= string
	description = "The profile used for SAP HANA Server. The list of certified profiles for SAP HANA Virtual Servers is available here: https://cloud.ibm.com/docs/sap?topic=sap-hana-iaas-offerings-profiles-intel-vs-vpc and for Bare Metal Servers here: https://cloud.ibm.com/docs/sap?topic=sap-hana-iaas-offerings-profiles-intel-bm-vpc. Details about all x86 instance profiles are available here: https://cloud.ibm.com/docs/vpc?topic=vpc-profiles. Example of Virtual Server Instance profile for SAP HANA: \"mx2-16x128\". Example of Bare Metal profile for SAP HANA: \"bx2d-metal-96x384 \". For more information about supported DB/OS and IBM VPC, check SAP Note 2927211: \"SAP Applications on IBM Virtual Private Cloud\"."
}

variable "DB_IMAGE" {
	type		= string
	description = "The OS image used for SAP HANA Server. A list of images is available here: https://cloud.ibm.com/docs/vpc?topic=vpc-about-images."
	default		= "ibm-redhat-8-6-amd64-sap-hana-5"
	validation {
		condition     = length(regexall("^(ibm-redhat-8-(4|6)-amd64-sap-hana|ibm-sles-15-(3|4)-amd64-sap-hana)-[0-9][0-9]*", var.DB_IMAGE)) > 0
             error_message = "The OS SAP DB_IMAGE must be one of  \"ibm-sles-15-3-amd64-sap-hana-x\", \"ibm-sles-15-4-amd64-sap-hana-x\", \"ibm-redhat-8-4-amd64-sap-hana-x\" or \"ibm-redhat-8-6-amd64-sap-hana-x\"."
 }
}

data "ibm_is_instance" "db-vsi" {
	count             = var.HANA_SERVER_TYPE == "virtual" ? 1 : 0
	depends_on = [module.db-vsi]
	name        = var.DB_HOSTNAME
}

data "ibm_is_bare_metal_server" "db-bms" {
	count             = var.HANA_SERVER_TYPE != "virtual" ? 1 : 0
	depends_on = [module.db-bms]
	name        = var.DB_HOSTNAME
}

# HANA SERVER PROFILE
resource "null_resource" "check_profile" {
  count             = var.DB_PROFILE != "" ? 1 : 0
  lifecycle {
    precondition {
      condition     = lower(trimspace(var.HANA_SERVER_TYPE)) == "virtual" ? contains(keys(jsondecode(file("${path.root}/modules/db-vsi/files/hana_vm_volume_layout.json")).profiles), "${var.DB_PROFILE}") : contains(keys(jsondecode(file("${path.root}/modules/db-bms/files/hana_bm_volume_layout.json")).profiles), "${var.DB_PROFILE}")
      error_message = "The chosen storage PROFILE for SAP HANA Server \"${var.DB_PROFILE}\" is not a certified storage profile. Please, chose the appropriate certified storage PROFILE for the HANA VSI form https://cloud.ibm.com/docs/sap?topic=sap-hana-iaas-offerings-profiles-intel-vs-vpc or for HANA BM Server from https://cloud.ibm.com/docs/sap?topic=sap-hana-iaas-offerings-profiles-intel-bm-vpc . Make sure the selected PROFILE is certified for the selected OS type and for the proceesing type (SAP Business One, OLTP, OLAP)"
    }
  }
}

##############################################################
# The variables and data sources used in SAP Ansible Modules.
##############################################################

variable "HANA_SID" {
	type		= string
	description = "The SAP system ID which identifies the SAP HANA system."
	default		= "HDB"
	validation {
		condition     = length(regexall("^[a-zA-Z][a-zA-Z0-9][a-zA-Z0-9]$", var.HANA_SID)) > 0  && !contains(["ADD", "ALL", "AMD", "AND", "ANY", "ARE", "ASC", "AUX", "AVG", "BIT", "CDC", "COM", "CON", "DBA", "END", "EPS", "FOR", "GET", "GID", "IBM", "INT", "KEY", "LOG", "LPT", "MAP", "MAX", "MIN", "MON", "NIX", "NOT", "NUL", "OFF", "OLD", "OMS", "OUT", "PAD", "PRN", "RAW", "REF", "ROW", "SAP", "SET", "SGA", "SHG", "SID", "SQL", "SUM", "SYS", "TMP", "TOP", "UID", "USE", "USR", "VAR"], var.HANA_SID)
		error_message = "The HANA_SID is not valid."
	}
}

variable "HANA_SYSNO" {
	type		= string
	description = "Specifies the instance number of the SAP HANA system."
	default		= "00"
	validation {
		condition     = var.HANA_SYSNO >= 0 && var.HANA_SYSNO <=97
		error_message = "The HANA_SYSNO is not valid."
	}
}

variable "HANA_MAIN_PASSWORD" {
	type		= string
	sensitive = true
	description = "Common password for all users that are created during the installation."
	validation {
		condition     = length(regexall("^(.{0,7}|.{15,}|[^0-9a-zA-Z]*)$", var.HANA_MAIN_PASSWORD)) == 0 && length(regexall("^[^0-9_][0-9a-zA-Z!@#$_]+$", var.HANA_MAIN_PASSWORD)) > 0
		error_message = "The HANA_MAIN_PASSWORD is not valid."
	}
}

variable "HANA_SYSTEM_USAGE" {
	type		= string
	description = "System Usage. Valid values: \"production\", \"test\", \"development\", \"custom\"."
	default		= "custom"
	validation {
		condition     = contains(["production", "test", "development", "custom" ], var.HANA_SYSTEM_USAGE )
		error_message = "The HANA_SYSTEM_USAGE must be one of: production, test, development, custom."
	}
}

variable "HANA_COMPONENTS" {
	type		= string
	description = "SAP HANA Components. Valid values: \"all\", \"client\", \"es\", \"ets\", \"lcapps\", \"server\", \"smartda\", \"streaming\", \"rdsync\", \"xs\", \"studio\", \"afl\", \"sca\", \"sop\", \"eml\", \"rme\", \"rtl\", \"trp\"."
	default		= "server"
	validation {
		condition     = contains(["all", "client", "es", "ets", "lcapps", "server", "smartda", "streaming", "rdsync", "xs", "studio", "afl", "sca", "sop", "eml", "rme", "rtl", "trp" ], var.HANA_COMPONENTS )
		error_message = "The HANA_COMPONENTS must be one of: all, client, es, ets, lcapps, server, smartda, streaming, rdsync, xs, studio, afl, sca, sop, eml, rme, rtl, trp."
	}
}

variable "KIT_SAPHANA_FILE" {
	type		= string
	description = "Path to SAP HANA ZIP file. As downloaded from SAP Support Portal."
	default		= "/storage/HANADB/SP07/Rev73/51057281.ZIP"
	validation {
		condition     = length(regex("(^|\\/|\\.)[[:digit:]]+\\.ZIP", var.KIT_SAPHANA_FILE)) > 0
		error_message = "The name of the KIT_SAPHANA_FILE is not valid."
	}
}

variable "HDB_CONCURRENT_JOBS" {
	type		= string
	description = "Number of concurrent jobs used to load and/or extract archives to HANA Host."
	default		= "23"
	validation {
		condition     = var.HDB_CONCURRENT_JOBS >= 1 && var.HDB_CONCURRENT_JOBS <=25
		error_message = "The HDB_CONCURRENT_JOBS is not valid."
	}
}
