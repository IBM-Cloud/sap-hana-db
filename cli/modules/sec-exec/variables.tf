variable "IP" {
    type = string
    description = "IP used to execute ansible"
}

variable "hana_main_password" {
	type		= string
	sensitive = true
	description = "hana_main_password"
}