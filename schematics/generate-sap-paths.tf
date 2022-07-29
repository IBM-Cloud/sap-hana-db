# List SAP PATHS
resource "local_file" "KIT_SAP_PATHS" {
  content = <<-DOC
${var.kit_saphana_file}
    DOC
  filename = "modules/precheck-ssh-exec/sap-paths-${var.HOSTNAME}"
}
