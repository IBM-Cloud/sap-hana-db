#### Ansible inventory.
resource "local_file" "ansible_inventory" {
  content = <<-DOC
all:
  hosts:
    db_host:
      ansible_host: "${lower(trimspace(var.HANA_SERVER_TYPE)) == "virtual" ? data.ibm_is_instance.db-vsi[0].primary_network_interface[0].primary_ip[0].address : data.ibm_is_bare_metal_server.db-bms[0].primary_network_interface[0].primary_ip[0].address}"
    DOC
  filename = "ansible/inventory.yml"
  count = (data.ibm_is_instance.db-vsi != [] || data.ibm_is_bare_metal_server.db-bms != []) ? 1 : 0
}

# Export Terraform variable values to an Ansible var_file
resource "local_file" "ansible_saphana-vars" {
  content = <<-DOC
---
# Ansible vars_file containing variable values passed from Terraform.
# Generated by "terraform plan&apply" command.
hana_profile: "${var.DB_PROFILE}"

# HANA DB configuration
hana_sid: "${upper(trimspace(var.HANA_SID))}"
hana_sysno: "${trimspace(var.HANA_SYSNO)}"
hana_main_password: "${trimspace(var.HANA_MAIN_PASSWORD)}"
hana_system_usage: "${trimspace(var.HANA_SYSTEM_USAGE)}"
hana_components: "${trimspace(var.HANA_COMPONENTS)}"
hdb_host: "${lower(trimspace(var.HANA_SERVER_TYPE)) == "virtual" ? data.ibm_is_instance.db-vsi[0].primary_network_interface[0].primary_ip[0].address : data.ibm_is_bare_metal_server.db-bms[0].primary_network_interface[0].primary_ip[0].address}"
hdb_instance_number: "${trimspace(var.HANA_SYSNO)}"
hdb_concurrent_jobs: "${trimspace(var.HDB_CONCURRENT_JOBS)}"

# SAP HANA Installation kit path
kit_saphana_file: "${trimspace(var.KIT_SAPHANA_FILE)}"
...
    DOC
  filename = "ansible/saphana-vars.yml"
  count = (data.ibm_is_instance.db-vsi != [] || data.ibm_is_bare_metal_server.db-bms != []) ? 1 : 0
}

# Export Terraform variable values to an Ansible var_file
resource "local_file" "tf_ansible_vars_generated_file" {
  source = "${lower(trimspace(var.HANA_SERVER_TYPE)) == "virtual" ? "${path.root}/modules/db-vsi/files/hana_vm_volume_layout.json" : "${path.root}/modules/db-bms/files/hana_bm_volume_layout.json"}"
  filename = "${lower(trimspace(var.HANA_SERVER_TYPE)) == "virtual" ? "ansible/hana_vm_volume_layout.json": "ansible/hana_bm_volume_layout.json"}"
  count = (data.ibm_is_instance.db-vsi != [] || data.ibm_is_bare_metal_server.db-bms != []) ? 1 : 0
}
