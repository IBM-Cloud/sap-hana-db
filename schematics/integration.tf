# Export Terraform variable values to an Ansible var_file
resource "local_file" "db_ansible_saphana-vars" {
  content = <<-DOC
---
#Ansible vars_file containing variable values passed from Terraform.
#Generated by "terraform plan&apply" command.

#HANA DB configuration
hana_sid: "${var.hana_sid}"
hana_sysno: "${var.hana_sysno}"
hana_main_password: "${var.hana_main_password}"
hana_system_usage: "${var.hana_system_usage}"
hana_components: "${var.hana_components}"

#Kits paths
kit_saphana_file: "${var.kit_saphana_file}"
...
    DOC
  filename = "ansible/saphanasinglehost-vars.yml"
}