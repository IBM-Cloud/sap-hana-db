# Automation Solution for SAP HANA 2.0 DB Deployment using Terraform and Ansible Integration

## Description
This automation solution is designed for the deployment of **SAP HANA 2.0 DB**. SAP HANA solution will be deployed on top of one of the following Operating Systems: **SUSE Linux Enterprise Server 15 SP 4 for SAP**, **SUSE Linux Enterprise Server 15 SP 3 for SAP**, **Red Hat Enterprise Linux 8.6 for SAP**, **Red Hat Enterprise Linux 8.4 for SAP** in an existing IBM Cloud Gen2 VPC, using an existing [bastion host with secure remote SSH access](https://github.com/IBM-Cloud/sap-bastion-setup).

The solution is based on Terraform remote-exec and Ansible playbooks executed by Schematics and it is implementing a 'reasonable' set of best practices for SAP server host configuration.

**It contains:**
- Terraform scripts for the deployment of a VSI or Bare Metal Server, in an EXISTING VPC, with Subnet and Security Group. The server is intended to be used for the data base instance. The automation has support for the following versions: Terraform >= 1.5.7 and IBM Cloud provider for Terraform >= 1.57.0.  Note: The deployment was tested with Terraform 1.5.7
- Bash scripts used for the checking of the prerequisites required by SAP server deployment and for the integration into a single step in IBM Schematics GUI of the VSI or Bare Metal Server provisioning and the **SAP HANA DB** installation.
- Ansible scripts to configure SAP HANA 2.0 node.
Please note that Ansible is started by Terraform and must be available on the same host.

In order to track the events specific to the resources deployed by this solution, the [IBM Cloud Activity Tracker](https://cloud.ibm.com/docs/activity-tracker?topic=activity-tracker-getting-started#gs_ov) to be used should be specified.   
IBM Cloud Activity Tracker service collects and stores audit records for API calls made to resources that run in the IBM Cloud. It can be used to monitor the activity of your IBM Cloud account, investigate abnormal activity and critical actions, and comply with regulatory audit requirements. In addition, you can be alerted on actions as they happen. 

## Contents:

- [1.1 Installation media](#11-installation-media)
- [1.2 Server Configuration](#12-server-configuration)
- [1.3 VPC Configuration](#13-vpc-configuration)
- [1.4 Files description and structure](#14-files-description-and-structure)
- [1.5 General Input Variabiles](#15-general-input-variables)
- [2.1 Prerequisites](#21-prerequisites)
- [2.2 Executing the deployment of **Standard SAP HANA** in GUI (Schematics)](#22-executing-the-deployment-of-sap-hana-in-gui-schematics)
- [2.3 Executing the deployment of **Standard SAP HANA** in CLI](#23-executing-the-deployment-of-sap-hana-in-cli)
- [3.1 Related links](#31-related-links)

## 1.1 Installation media

SAP HANA installation media used for this deployment is the default one for **SAP HANA, platform edition 2.0 SPS07** available at SAP Support Portal under *INSTALLATION AND UPGRADE* area and it has to be provided manually in the input parameter file.

## 1.2 Server Configuration

The Server is deployed with one of the following Operating Systems for DB server: **Red Hat Enterprise Linux 8.6 for SAP HANA (amd64)**, **Red Hat Enterprise Linux 8.4 for SAP HANA (amd64)**, **SUSE Linux Enterprise Server 15 SP 4 for SAP HANA (amd64)**, or **SUSE Linux Enterprise Server 15 SP 3 for SAP HANA (amd64)**. The SSH keys are configured to allow root user access. The following storage volumes are creating during the provisioning:

SAP HANA DB Server Disks:
- the disk sizes depend on the selected profile, according to [Intel Virtual Server certified profiles on VPC infrastructure for SAP HANA](https://cloud.ibm.com/docs/sap?topic=sap-hana-iaas-offerings-profiles-intel-vs-vpc) - Last updated 2023-12-28 and to [Bare metal servers certified profiles on VPC infrastructure for SAP HANA](https://cloud.ibm.com/docs/sap?topic=sap-hana-iaas-offerings-profiles-intel-bm-vpc) - Last updated 2024-05-13

Note: For SAP HANA on a VSI, according to [Intel Virtual Server certified profiles on VPC infrastructure for SAP HANA](https://cloud.ibm.com/docs/sap?topic=sap-hana-iaas-offerings-profiles-intel-vs-vpc#vx2d-16x224) - Last updated 2022-01-28 and to [Storage design considerations](https://cloud.ibm.com/docs/sap?topic=sap-storage-design-considerations) - Last updated 2024-01-25, LVM will be used for **`/hana/data`**, **`hana/log`**, **`/hana/shared`** and **`/usr/sap`**, for all storage profiles, with the following exceptions:
- **`/hana/data`** and **`/hana/shared`** for the following profiles: **`vx2d-44x616`** and **`vx2d-88x1232`**
- **`/hana/shared`** for the following profiles: **`vx2d-144x2016`**, **`vx2d-176x2464`**, **`ux2d-36x1008`**, **`ux2d-48x1344`**, **`ux2d-72x2016`**, **`ux2d-100x2800`**, **`ux2d-200x5600`**.

For example, in case of deploying a SAP HANA on a VSI, using the value `mx2-16x128` for the VSI profile , the automation will execute the following storage setup:  
- 3 volumes x 500 GB each for `<sid>_hana_vg` volume group
  - the volume group will contain the following logical volumes (created with three stripes):
    - `<sid>_hana_data_lv` - size 988 GB
    - `<sid>_hana_log_lv` - size 256 GB
    - `<sid>_hana_shared` - size 256 GB
- 1 volume x 50 GB for `/usr/sap` (volume group: `<sid>_usr_sap_vg`, logical volume: `<sid>_usr_sap_lv`)
- 1 volume x 10 GB for a 2 GB SWAP logical volume (volume group: `<sid>_swap_vg`, logical volume: `<sid>_swap_lv`)

In case of deploying a SAP HANA on a Bare Metal Server, using the value `bx2d-metal-96x384` for the Bare Metal Server profile, the automation will execute the following storage setup:  
- 4 disks x 2.9 TB each for `<sid>_vg0` volume group
  - the volume group will contain the following logical volumes (created with raid10, mirror and two stripes):
    - `<sid>_hana_log_lv` - size 384 GB
    - `<sid>_hana_shared` - size 384 GB
- 4 disks x 2.9 TB each for `<sid>_vg1` volume group
  - the volume group will contain the following logical volumes (created with raid10, mirror and two stripes):
    - `<sid>_hana_data_lv` - size 100%FREE
- 1 directory `/usr/sap`
- 1 SWAP file of 2 GB `/<sid>_swapfile`

## 1.3 VPC Configuration

The Security Rules inherited from BASTION deployment are the following:
- Allow all traffic in the Security group for private networks.
- Allow outbound traffic  (ALL for port 53, TCP for ports 80, 443, 8443)
- Allow inbound SSH traffic (TCP for port 22) from IBM Schematics Servers.

## 1.4 Files description and structure

 - `modules` - directory containing the terraform modules
 - `main.tf` - contains the configuration of the VSI or Bare Metal Server for the deployment of the current SAP solution.
 - `output.tf` - contains the code for the information to be displayed after the VSI or Bare Metal Server is created (Hostname, Private IP)
 - `integration.tf` - contains the integration code that makes the SAP variabiles from Terraform available to Ansible.
 - `provider.tf` - contains the IBM Cloud Provider data in order to run `terraform init` command.
 - `variables.tf` - contains variables for the VPC and VSI or Bare Metal Server
 - `versions.tf` - contains the minimum required versions for terraform and IBM Cloud provider.

## 1.5 General Input Variables

The following parameters can be set in the Schematics workspace: VPC, Subnet, Security group, Resource group, Hostname, Profile, Image, SSH Keys and your SAP system configuration variables, as below:

**VSI/Bare Metal Server input parameters:**

Parameter | Description
----------|------------
IBMCLOUD_API_KEY | IBM Cloud API key (Sensitive* value). The IBM Cloud API Key can be created [here](https://cloud.ibm.com/iam/apikeys).
SSH_KEYS | List of SSH Keys UUIDs that are allowed to SSH as root to the VSI or Bare Metal Server. Can contain one or more IDs. The list of SSH Keys is available [here](https://cloud.ibm.com/vpc-ext/compute/sshKeys). <br /> Sample input (use your own SSH UUIDs from IBM Cloud):<br /> ["r010-5db21872-c98f-4945-9f69-71c637b1da50", "r010-6dl21976-c97f-7935-8dd9-72c637g1ja31"]
BASTION_FLOATING_IP | The FLOATING IP can be copied from the Bastion Server Deployment "OUTPUTS" at the end of "Apply plan successful" message.
RESOURCE_GROUP | The name of an EXISTING Resource Group for VSI or Bare Metal Server and Volumes resources. <br /> Default value: "Default". The list of Resource Groups is available [here](https://cloud.ibm.com/account/resource-groups).
REGION | The cloud region where to deploy the solution. <br /> The regions and zones for VPC are listed [here](https://cloud.ibm.com/docs/containers?topic=containers-regions-and-zones#zones-vpc). <br /> Review supported locations in IBM Cloud Schematics [here](https://cloud.ibm.com/docs/schematics?topic=schematics-locations).<br /> Sample value: eu-de.
ZONE | The cloud zone where to deploy the solution. <br /> Sample value: eu-de-2.
VPC | The name of an EXISTING VPC. The list of VPCs is available [here](https://cloud.ibm.com/vpc-ext/network/vpcs)
SUBNET | The name of an EXISTING Subnet. The list of Subnets is available [here](https://cloud.ibm.com/vpc-ext/network/subnets). 
SECURITY_GROUP | The name of an EXISTING Security group. The list of Security Groups is available [here](https://cloud.ibm.com/vpc-ext/network/securityGroups). 
HANA_SERVER_TYPE | The type of SAP HANA Server. Allowed vales: "virtual" or "bare metal"
DB_HOSTNAME | The Hostname for the HANA VSI or Bare Metal Server. The hostname should be up to 13 characters as required by SAP.  For more information on rules regarding hostnames for SAP systems, check [SAP Note 611361: Hostnames of SAP ABAP Platform servers](https://launchpad.support.sap.com/#/notes/%20611361)
DB_PROFILE | The instance profile used for the SAP HANA Server. The list of the certified profiles for SAP HANA on a VSI is available [here](https://cloud.ibm.com/docs/sap?topic=sap-hana-iaas-offerings-profiles-intel-vs-vpc). The list of the certified profiles for SAP HANA on a Bare Metal Server is available [here](https://cloud.ibm.com/docs/sap?topic=sap-hana-iaas-offerings-profiles-intel-bm-vpc). <br> Details about all x86 instance profiles are available [here](https://cloud.ibm.com/docs/vpc?topic=vpc-profiles). <br>  For more information about supported DB/OS and IBM Gen 2 Servers, check [SAP Note 2927211: SAP Applications on IBM Virtual Private Cloud](https://launchpad.support.sap.com/#/notes/2927211) <br />
DB_IMAGE | The OS image used for HANA VSI or Bare Metal Server (See Obs*). A list of images is available [here](https://cloud.ibm.com/docs/vpc?topic=vpc-about-images).<br /> Default value: ibm-redhat-8-6-amd64-sap-hana-5

**Activity Tracker input parameters**

Parameter | Description
----------|------------
ATR_NAME | ATR_NAME The name of an existent Activity Tracker instance, in the same region chosen for SAP system deployment. The list of available Activity Tracker is available here Example: ATR_NAME="Activity-Tracker-SAP-eu-de".   

**SAP input parameters:**

Parameter | Description | Requirements
----------|-------------|-------------
HANA_SID | The SAP system ID identifies the SAP HANA system | <ul><li>Consists of exactly three alphanumeric characters</li><li>Has a letter for the first character</li><li>Does not include any of the reserved IDs listed in SAP Note 1979280</li></ul>|
HANA_SYSNO | Specifies the instance number of the SAP HANA system| <ul><li>Two-digit number from 00 to 97</li><li>Must be unique on a host</li></ul>
HANA_MAIN_PASSWORD | Common password for all users that are created during the installation (See Obs*). | <ul><li>It must be 8 to 14 characters long</li><li>It must consist of at least one digit (0-9), one lowercase letter (a-z), and one uppercase letter (A-Z).</li><li>It can only contain the following characters: a-z, A-Z, 0-9, !, @, #, $, _</li><li>It must not start with a digit or an underscore ( _ )</li></ul> <br /> (Sensitive* value)
HANA_SYSTEM_USAGE  | System Usage | Default: custom<br> Valid values: production, test, development, custom
HANA_COMPONENTS | SAP HANA Components | Default: server<br> Valid values: all, client, es, ets, lcapps, server, smartda, streaming, rdsync, xs, studio, afl, sca, sop, eml, rme, rtl, trp
KIT_SAPHANA_FILE | Path to SAP HANA ZIP file (See Obs*). | As downloaded from SAP Support Portal

**Obs***: <br />
 - **HANA Main Password.**
The password for the HANA system (Sensitive* value) will be hidden during the schematics apply step and will not be available after the deployment.

- **Sensitive** - The variable value is not displayed in your Schematics logs and it is hidden in the input field.<br />
- The following parameters should have the same values as the ones set for the BASTION server: REGION, ZONE, VPC, SUBNET, SECURITYGROUP.
- For any manual change in the terraform code, you have to make sure that you use a certified image based on the SAP NOTE: 2927211.
- OS **image** for **SAP HANA Server.** 
    - The list of available VPC Operating Systems supported by SAP: SAP note '2927211 - SAP Applications on IBM Virtual Private Cloud (VPC) Infrastructure environment' https://launchpad.support.sap.com/#/notes/2927211;
-  SAP **HANA Installation path kit**
     - Supported SAP HANA versions on RHEL8.4, RHEL8.6, SLES15.3 and SLES15.4: HANA 2.0 SP 7 Rev 73, kit file:51057281.ZIP
     - Example for Red Hat 8 or Suse 15: KIT_SAPHANA_FILE = "/storage/HANADB/SP07/Rev73/51057281.ZIP"
     - Default variable value:  KIT_SAPHANA_FILE = "/storage/HANADB/SP07/Rev73/51057281.ZIP"

**Installation media validated for this solution:**

---
SAP HANA
---

Component | Version | Filename
----------|-------------|-------------
HANA DB | 2.0 SPS07 rev73 | 51057281.ZIP

**OS images validated for this solution:**

OS version | Image | Role
-----------|-----------|-----------
Red Hat Enterprise Linux 8.6 for SAP HANA (amd64) | ibm-redhat-8-6-amd64-sap-hana-5 | DB
Red Hat Enterprise Linux 8.4 for SAP HANA (amd64) | ibm-redhat-8-4-amd64-sap-hana-9 | DB
SLES for SAP Applications 15 SP4 (amd64) | ibm-sles-15-4-amd64-sap-hana-6 | DB
SLES for SAP Applications 15 SP3 (amd64) | ibm-sles-15-4-amd64-sap-hana-9 | DB

## 2.1 Prerequisites

- A Deployment Server (BASTION Server) in the same VPC should exist. For more information, see https://github.com/IBM-Cloud/sap-bastion-setup.
- On the Deployment Server download the SAP kits from the SAP Portal. Make note of the download locations. Ansible decompresses all of the archive kits.
- Create or retrieve an IBM Cloud API key. The API key is used to authenticate with the IBM Cloud platform and to determine your permissions for IBM Cloud services.
- Create or retrieve your SSH key ID. You need the 40-digit UUID for the SSH key, not the SSH key name.
- Required IAM permissions for deploying SAP HANA on Bare Metal: `Bare Metal Console Administrator` role to access the ESXi Direct Console User Interface (DCUI) and `Bare Metal Advanced Network Operator` role to modify IP spoofing and infrastructure NAT configuration on network interfaces - https://cloud.ibm.com/docs/vpc?topic=vpc-planning-for-bare-metal-servers

## 2.2 Executing the deployment of **SAP HANA** in GUI (Schematics)

### IBM Cloud API Key
The IBM Cloud API Key should be provided as input value of type sensitive for "IBMCLOUD_API_KEY" variable, in `IBM Schematics -> Workspaces -> <Workspace name> -> Settings` menu.
The IBM Cloud API Key can be created [here](https://cloud.ibm.com/iam/apikeys).

### Input parameters

The following parameters can be set in the Schematics workspace: VPC, Subnet, Security group, Resource group, Hostname, Profile, Image, SSH Keys and your SAP system configuration variables. These are described in [General input variables Section](#15-general-input-variables) section.

Beside [General input variables Section](#15-general-input-variables), the below ones, in IBM Schematics have specific description and GUI input options:

**VSI or Bare Metal Server input parameters:**

Parameter | Description
----------|------------
PRIVATE_SSH_KEY | id_rsa private key content (Sensitive* value) in OpenSSH format. This private key it is used only during the terraform provisioning and it is recommended to be changed after the SAP deployment.
ID_RSA_FILE_PATH | File path for PRIVATE_SSH_KEY. It will be automatically generated. If it is changed, it must contain the relative path from git repo folders. <br /> Default value: "ansible/id_rsa".
BASTION_FLOATING_IP | The FLOATING IP from the Bastion Server. It can be found at the end of the Bastion Server deployment log, in "Outputs", before "Command finished successfully" message.

### Steps to follow:

1.  Make sure that you have the [required IBM Cloud IAM
    permissions](https://cloud.ibm.com/docs/vpc?topic=vpc-managing-user-permissions-for-vpc-resources) to
    create and work with VPC infrastructure and you are [assigned the
    correct
    permissions](https://cloud.ibm.com/docs/schematics?topic=schematics-access) to
    create the workspace in Schematics and deploy resources.
2.  [Generate an SSH
    key](https://cloud.ibm.com/docs/vpc?topic=vpc-ssh-keys).
    The SSH key is required to access the provisioned VPC virtual server
    instances via the bastion host. After you have created your SSH key,
    make sure to [upload this SSH key to your IBM Cloud
    account](https://cloud.ibm.com/docs/vpc-on-classic-vsi?topic=vpc-on-classic-vsi-managing-ssh-keys#managing-ssh-keys-with-ibm-cloud-console) in
    the VPC region and resource group where you want to deploy the SAP solution
3.  Create the Schematics workspace:
    1.  From the IBM Cloud menu
    select [Schematics](https://cloud.ibm.com/schematics/overview).
        - Push the `Create workspace` button.
        - Provide the URL of the Github repository of this solution
        - Select the latest Terraform version.
        - Click on `Next` button
        - Provide a name, the resources group and location for your workspace
        - Push `Next` button
        - Review the provided information and then push `Create` button to create your workspace
    2.  On the workspace **Settings** page, 
        - In the **Input variables** section, review the default values for the input variables and provide alternatives if desired.
        - Click **Save changes**.
4.  From the workspace **Settings** page, click **Generate plan** 
5.  From the workspace **Jobs** page, the logs of your Terraform
    execution plan can be reviewed.
6.  Apply your Terraform template by clicking **Apply plan**.
7.  Review the log file to ensure that no errors occurred during the
    provisioning, modification, or deletion process.

The output of the Schematics Apply Plan will list the public/private IP addresses
of the VSI or Bare Metal host, the hostname, the subnet, the security group, the activity tracker name, the VPC and SAP HANA SID.

## 2.3 Executing the deployment of **SAP HANA** in CLI

### IBM Cloud API Key
For the script configuration add your IBM Cloud API Key in terraform planning phase command 'terraform plan --out plan1'.
You can create an API Key [here](https://cloud.ibm.com/iam/apikeys).
 
### Input parameter file
The solution is configured and customized based on the input values for the variables in the file `input.auto.tfvars`
Provide your own values for VPC, Subnet, Security group, Resource Group, Hostname, Profile, Image, SSH Keys, Activity Tracker, Server Type like in the sample below:

**VSI or Bare Metal input parameters**

```shell
##########################################################
# General VPC variables
######################################################

REGION = "eu-de"
# Region for SAP HANA server. Supported regions: https://cloud.ibm.com/docs/containers?topic=containers-regions-and-zones#zones-vpc
# Example: REGION = "eu-de"

ZONE = "eu-de-2"
# Availability zone for SAP HANA server. Supported zones: https://cloud.ibm.com/docs/containers?topic=containers-regions-and-zones#zones-vpc
# Example: ZONE = "eu-de-2"

VPC = "ic4sap"
# EXISTING VPC, previously created by the user in the same region as the VSI. The list of available VPCs: https://cloud.ibm.com/vpc-ext/network/vpcs
# Example: VPC = "ic4sap"

SECURITY_GROUP = "ic4sap-securitygroup"
# EXISTING Security group, previously created by the user in the same VPC. The list of available Security Groups: https://cloud.ibm.com/vpc-ext/network/securityGroups
# Example: SECURITY_GROUP = "ic4sap-securitygroup"

RESOURCE_GROUP = "wes-automation"
# EXISTING Resource group, previously created by the user. The list of available Resource Groups: https://cloud.ibm.com/account/resource-groups
# Example: RESOURCE_GROUP = "wes-automation"

SUBNET = "ic4sap-subnet"
# EXISTING Subnet in the same region and zone as the SAP HANA server, previously created by the user. The list of available Subnets: https://cloud.ibm.com/vpc-ext/network/subnets
# Example: SUBNET = "ic4sap-subnet"

SSH_KEYS = ["r010-5db21872-c98f-4945-9f69-71c637b1da50", "r010-6dl21976-c97f-7935-8dd9-72c637g1ja31"]
# List of SSH Keys UUIDs that are allowed to SSH as root to the SAP HANA server. The SSH Keys should be created for the same region as the VSI. The list of available SSH Keys UUIDs: https://cloud.ibm.com/vpc-ext/compute/sshKeys
# Example: SSH_KEYS = ["r010-5db21872-c98f-4945-9f69-71c637b1da50", "r010-6dl21976-c97f-7935-8dd9-72c637g1ja31"]

ID_RSA_FILE_PATH = "ansible/id_rsa"
# Your existing id_rsa private key file path in OpenSSH format with 0600 permissions. The private key must be in OpenSSH format.
# This private key is used only during the provisioning and it is recommended to be changed after the SAP deployment.
# It must contain the relative or absoute path from your Bastion.
# Examples: "ansible/id_rsa_hana_single_vsi" , "~/.ssh/id_rsa_hana_single_vsi" , "/root/.ssh/id_rsa".

##########################################################
# Activity Tracker variables
##########################################################

ATR_NAME = "Activity-Tracker-SAP-eu-de"
# The name of an existent Activity Tracker instance, in the same region chosen for SAP system deployment.
# Example: ATR_NAME="Activity-Tracker-SAP-eu-de"

##########################################################
# SAP HANA Server variables
##########################################################

HANA_SERVER_TYPE = ""
# The type of SAP HANA Server. Allowed vales: "virtual" or "bare metal"

DB_HOSTNAME = "saphanadb1"
# The Hostname for the DB VSI. The hostname should be up to 13 characters, as required by SAP
# Example: HOSTNAME = "ic4sap"

DB_PROFILE = "mx2-16x128"
# The profile used for SAP HANA Server. 
# The list of certified profiles for SAP HANA Virtual Servers is available here: https://cloud.ibm.com/docs/sap?topic=sap-hana-iaas-offerings-profiles-intel-vs-vpc
# The list of certified profiles for SAP HANA Bare Metal Servers is available here: https://cloud.ibm.com/docs/sap?topic=sap-hana-iaas-offerings-profiles-intel-bm-vpc. 
# Details about all x86 instance profiles are available here: https://cloud.ibm.com/docs/vpc?topic=vpc-profiles.
# Example of Virtual Server Instance profile for SAP HANA: DB_PROFILE ="mx2-16x128". 
# Example of Bare Metal profile for SAP HANA: DB_PROFILE = "bx2d-metal-96x384". 
# For more information about supported DB/OS and IBM VPC, check SAP Note 2927211: "SAP Applications on IBM Virtual Private Cloud".

DB_IMAGE = "ibm-redhat-8-6-amd64-sap-hana-5"
# OS image for DB Server. Validated OS images for SAP HANA Server: ibm-redhat-8-6-amd64-sap-hana-5, ibm-redhat-8-4-amd64-sap-hana-9, ibm-sles-15-4-amd64-sap-hana-6, ibm-sles-15-3-amd64-sap-hana-9.
# The list of available VPC Operating Systems supported by SAP: SAP note '2927211 - SAP Applications on IBM Virtual Private Cloud (VPC) Infrastructure environment' https://launchpad.support.sap.com/#/notes/2927211; The list of all available OS images: https://cloud.ibm.com/docs/vpc?topic=vpc-about-images
# Example: DB_IMAGE = "ibm-sles-15-4-amd64-sap-hana-6"
```

Edit your SAP system configuration variables that will be passed to the ansible automated deployment:

```shell
##########################################################
# SAP HANA configuration
##########################################################

HANA_SID = "HDB"
# SAP HANA system ID. Should follow the SAP rules for SID naming.
# Example: HANA_SID = "HDB"

HANA_SYSNO = "00"
# SAP HANA instance number. Should follow the SAP rules for instance number naming.
# Example: HANA_SYSNO = "01"

HANA_SYSTEM_USAGE = "custom"
# System usage. Default: custom. Suported values: production, test, development, custom
# Example: HANA_SYSTEM_USAGE = "custom"

HANA_COMPONENTS = "server"
# SAP HANA Components. Default: server. Supported values: all, client, es, ets, lcapps, server, smartda, streaming, rdsync, xs, studio, afl, sca, sop, eml, rme, rtl, trp
# Example: HANA_COMPONENTS = "server"

KIT_SAPHANA_FILE = "/storage/HANADB/SP07/Rev73/51057281.ZIP"
# SAP HANA Installation kit path
# Supported SAP HANA versions on RHEL8 and SLES15: HANA 2.0 SP 5 Rev 57, kit file: 51055299.ZIP
# Example for RHEL8 or SLES15: KIT_SAPHANA_FILE = "/storage/HANADB/SP07/Rev73/51057281.ZIP"
```

## Steps to reproduce:

For initializing terraform:

```shell
terraform init
```

For planning phase:

```shell
terraform plan --out plan1
# you will be asked for the following sensitive variables: 'IBMCLOUD_API_KEY' and 'HANA_MAIN_PASSWORD'.
```

For apply phase:

```shell
terraform apply
```

For destroy:

```shell
terraform destroy
# you will be asked for the following sensitive variables as a destroy confirmation phase:
'IBMCLOUD_API_KEY' and 'HANA_MAIN_PASSWORD'.
```

### 3.1 Related links:

- [How to create a BASTION/STORAGE VSI for SAP in IBM Schematics](https://github.com/IBM-Cloud/sap-bastion-setup)
- [Securely Access Remote Instances with a Bastion Host](https://www.ibm.com/cloud/blog/tutorial-securely-access-remote-instances-with-a-bastion-host)
- [VPNs for VPC overview: Site-to-site gateways and Client-to-site servers.](https://cloud.ibm.com/docs/vpc?topic=vpc-vpn-overview)
- [IBM Cloud Schematics](https://www.ibm.com/cloud/schematics)
