variable "KIT_SAPHANA_FILE" {
	type		= string
	description = "kit_saphana_file"
    validation {
    condition = fileexists("${var.KIT_SAPHANA_FILE}") == true
    error_message = "The PATH  does not exist."
    }
}

