variable "REGION" {
	type		= string
	description	= "Cloud Region"
	validation {
		condition     = contains(["au-syd", "jp-osa", "jp-tok", "eu-de", "eu-gb", "ca-tor", "us-south", "us-east", "br-sao"], var.REGION )
		error_message = "The REGION must be one of: au-syd, jp-osa, jp-tok, eu-de, eu-gb, ca-tor, us-south, us-east, br-sao."
	}
}

variable "ZONE" {
	type		= string
	description	= "Cloud Zone"
	validation {
		condition     = length(regexall("^(au-syd|jp-osa|jp-tok|eu-de|eu-gb|ca-tor|us-south|us-east|br-sao)-(1|2|3)$", var.ZONE)) > 0
		error_message = "The ZONE is not valid."
	}
}

variable "VPC" {
	type		= string
	description = "EXISTING VPC name"
	validation {
		condition     = length(regexall("^([a-z]|[a-z][-a-z0-9]*[a-z0-9]|[0-9][-a-z0-9]*([a-z]|[-a-z][-a-z0-9]*[a-z0-9]))$", var.VPC)) > 0
		error_message = "The VPC name is not valid."
	}
}

variable "SUBNET" {
	type		= string
	description = "EXISTING Subnet name"
	validation {
		condition     = length(regexall("^([a-z]|[a-z][-a-z0-9]*[a-z0-9]|[0-9][-a-z0-9]*([a-z]|[-a-z][-a-z0-9]*[a-z0-9]))$", var.SUBNET)) > 0
		error_message = "The SUBNET name is not valid."
	}
}

variable "SECURITY_GROUP" {
	type		= string
	description = "EXISTING Security group name"
	validation {
		condition     = length(regexall("^([a-z]|[a-z][-a-z0-9]*[a-z0-9]|[0-9][-a-z0-9]*([a-z]|[-a-z][-a-z0-9]*[a-z0-9]))$", var.SECURITY_GROUP)) > 0
		error_message = "The SECURITY_GROUP name is not valid."
	}
}

variable "RESOURCE_GROUP" {
  type        = string
  description = "Resource Group"
  default     = "Default"
}

variable "HOSTNAME" {
	type		= string
	description = "VSI Hostname"
	validation {
		condition     = length(var.HOSTNAME) <= 13 && length(regexall("^(([a-zA-Z0-9]|[a-zA-Z0-9][a-zA-Z0-9\\-]*[a-zA-Z0-9])\\.)*([A-Za-z0-9]|[A-Za-z0-9][A-Za-z0-9\\-]*[A-Za-z0-9])$", var.HOSTNAME)) > 0
		error_message = "The HOSTNAME is not valid."
	}
}


variable "PROFILE" {
	type		= string
	description = "DB VSI Profile. The certified profiles for SAP HANA in IBM VPC: https://cloud.ibm.com/docs/sap?topic=sap-hana-iaas-offerings-profiles-intel-vs-vpc"
	default		= "mx2-16x128"
	validation {
		condition     = contains(keys(jsondecode(file("files/hana_volume_layout.json")).profiles), "${var.PROFILE}")
		error_message = "The chosen storage PROFILE for HANA VSI \"${var.PROFILE}\" is not a certified storage profile. Please, chose the appropriate certified storage PROFILE for the HANA VSI from  https://cloud.ibm.com/docs/sap?topic=sap-hana-iaas-offerings-profiles-intel-vs-vpc . Make sure the selected PROFILE is certified for the selected OS type and for the proceesing type (SAP Business One, OLTP, OLAP)"
	}
}

variable "IMAGE" {
	type		= string
	description = "DB VSI OS Image"
	default		= "ibm-redhat-8-6-amd64-sap-hana-2"
	validation {
		condition     = length(regexall("^(ibm-redhat-8-(4|6)-amd64-sap-hana|ibm-sles-15-(3|4)-amd64-sap-hana)-[0-9][0-9]*", var.IMAGE)) > 0
             error_message = "The OS SAP DB-IMAGE must be one of  \"ibm-sles-15-3-amd64-sap-hana-x\", \"ibm-sles-15-4-amd64-sap-hana-x\", \"ibm-redhat-8-4-amd64-sap-hana-2\" or \"ibm-redhat-8-6-amd64-sap-hana-x\"."
 	}
}

variable "SSH_KEYS" {
	type		= list(string)
	description = "SSH Keys ID list to access the VSI"
	validation {
		condition     = var.SSH_KEYS == [] ? false : true && var.SSH_KEYS == [""] ? false : true
		error_message = "At least one SSH KEY is needed to be able to access the VSI."
	}
}

variable "hana_sid" {
	type		= string
	description = "hana_sid"
}

variable "hana_sysno" {
	type		= string
	description = "hana_sysno"
}

variable "hana_main_password" {
	type		= string
	sensitive = true
	description = "hana_main_password"
}

variable "hana_system_usage" {
	type		= string
	description = "hana_system_usage"
	default		= "custom"
}

variable "hana_components" {
	type		= string
	description = "hana_components"
	default		= "server"
}

variable "kit_saphana_file" {
	type		= string
	description = "kit_saphana_file"
}
