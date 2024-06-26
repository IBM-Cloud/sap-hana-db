variable "KIT_SAPHANA_FILE" {
	type		= string
	description = "KIT_SAPHANA_FILE"
    validation {
    condition = fileexists("${var.KIT_SAPHANA_FILE}") == true
    error_message = "The PATH  does not exist."
    }
}
