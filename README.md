# Automation solution for SAP HANA 2.0 DB deployment using Terraform and Ansible integration

## Description
This automation solution is designed for the deployment of **SAP HANA 2.0 DB**. SAP HANA solution will be deployed on top of one of the following Operating Systems: **SUSE Linux Enterprise Server 15 SP 4 for SAP**, **SUSE Linux Enterprise Server 15 SP 3 for SAP**, **Red Hat Enterprise Linux 8.6 for SAP**, **Red Hat Enterprise Linux 8.4 for SAP** in an existing IBM Cloud Gen2 VPC, using an existing bastion host with secure remote SSH access.

## Contents:

- [1.1 Installation media](#11-installation-media)
- [1.2 VSI Configuration](#12-vsi-configuration)
- [1.3 VPC Configuration](#13-vpc-configuration)
- [1.4 Files description and structure](#14-files-description-and-structure)
- [1.5 General input variabiles](#15-general-input-variables)
- [2.1 Executing the deployment of **Standard SAP HANA** in GUI (Schematics)](#21-executing-the-deployment-of-sap-hana-in-gui-schematics)
- [2.2 Executing the deployment of **Standard SAP HANA** in CLI](#22-executing-the-deployment-of-sap-hana-in-cli)
- [3.1 Related links](#31-related-links)

## 1.1 Installation media

SAP HANA installation media used for this deployment is the default one for **SAP HANA, platform edition 2.0 SPS05** available at SAP Support Portal under *INSTALLATION AND UPGRADE* area and it has to be provided manually in the input parameter file.

## 1.2 VSI Configuration

The VSIs are deployed with one of the following Operating Systems for DB server: SUSE Linux Enterprise Server 15 SP 3 for SAP HANA (amd64), SUSE Linux Enterprise Server 15 SP 4 for SAP HANA (amd64), Red Hat Enterprise Linux 8.4 for SAP HANA (amd64) or Red Hat Enterprise Linux 8.6 for SAP HANA (amd64). The SSH keys are configured to allow root user access. The following storage volumes are creating during the provisioning:

HANA DB VSI Disks:
- the disk sizes depend on the selected profile, according to [Intel Virtual Server certified profiles on VPC infrastructure for SAP HANA](https://cloud.ibm.com/docs/sap?topic=sap-hana-iaas-offerings-profiles-intel-vs-vpc) - Last updated 2022-01-28

Note: LVM will be used for **`/hana/data`**, **`hana/log`**, **`/hana/shared`** and **`/usr/sap`**, for all storage profiles, excepting **`vx2d-44x616`** and **`vx2d-88x1232`** profiles, where **`/hana/data`** and **`/hana/shared`** won't be manged by LVM, according to [Intel Virtual Server certified profiles on VPC infrastructure for SAP HANA](https://cloud.ibm.com/docs/sap?topic=sap-hana-iaas-offerings-profiles-intel-vs-vpc#vx2d-16x224) - Last updated 2022-01-28 and to [Storage design considerations](https://cloud.ibm.com/docs/sap?topic=sap-storage-design-considerations#hana-iaas-mx2-16x128-32x256-configure) - Last updated 2022-05-19

For example, in case of deploying a HANA VM, using the default value for VSI profile `mx2-16x128`, the automation will execute the following storage setup:  
- 3 volumes x 500 GB each for `<sid>_hana_vg` volume group
  - the volume group will contain the following logical volumes (created with three stripes):
    - `<sid>_hana_data_lv` - size 988 GB
    - `<sid>_hana_log_lv` - size 256 GB
    - `<sid>_hana_shared` - size 256 GB
- 1 volume x 50 GB for `/usr/sap` (volume group: `<sid>_usr_sap_vg`, logical volume: `<sid>_usr_sap_lv`)
- 1 volume x 10 GB for a 2 GB SWAP logical volume (volume group: `<sid>_swap_vg`, logical volume: `<sid>_swap_lv`)

## 1.3 VPC Configuration

The Security Rules inherited from BASTION deployment are the following:
- Allow all traffic in the Security group for private networks.
- Allow outbound traffic  (ALL for port 53, TCP for ports 80, 443, 8443)
- Allow inbound SSH traffic (TCP for port 22) from IBM Schematics Servers.


## 1.4 Files description and structure

 - `modules` - directory containing the terraform modules
 - `main.tf` - contains the configuration of the VSI for the deployment of the current SAP solution.
 - `output.tf` - contains the code for the information to be displayed after the VSI is created (Hostname, Private IP)
 - `integration.tf` - contains the integration code that makes the SAP variabiles from Terraform available to Ansible.
 - `provider.tf` - contains the IBM Cloud Provider data in order to run `terraform init` command.
 - `variables.tf` - contains variables for the VPC and VSI
 - `versions.tf` - contains the minimum required versions for terraform and IBM Cloud provider.


## 1.5 General Input variables

The following parameters can be set in the Schematics workspace: VPC, Subnet, Security group, Resource group, Hostname, Profile, Image, SSH Keys and your SAP system configuration variables, as below:

**VSI input parameters:**

Parameter | Description
----------|------------
IBMCLOUD_API_KEY | IBM Cloud API key (Sensitive* value).
PRIVATE_SSH_KEY | id_rsa private key content (Sensitive* value).
SSH_KEYS | List of SSH Keys UUIDs that are allowed to SSH as root to the VSI. Can contain one or more IDs. The list of SSH Keys is available [here](https://cloud.ibm.com/vpc-ext/compute/sshKeys). <br /> Sample input (use your own SSH UUIDs from IBM Cloud):<br /> [ "r010-57bfc315-f9e5-46bf-bf61-d87a24a9ce7a" , "r010-3fcd9fe7-d4a7-41ce-8bb3-d96e936b2c7e" ]
BASTION_FLOATING_IP | The FLOATING IP from the Bastion Server.
RESOURCE_GROUP | The name of an EXISTING Resource Group for VSIs and Volumes resources. <br /> Default value: "Default". The list of Resource Groups is available [here](https://cloud.ibm.com/account/resource-groups).
REGION | The cloud region where to deploy the solution. <br /> The regions and zones for VPC are listed [here](https://cloud.ibm.com/docs/containers?topic=containers-regions-and-zones#zones-vpc). <br /> Review supported locations in IBM Cloud Schematics [here](https://cloud.ibm.com/docs/schematics?topic=schematics-locations).<br /> Sample value: eu-de.
ZONE | The cloud zone where to deploy the solution. <br /> Sample value: eu-de-2.
VPC | The name of an EXISTING VPC. The list of VPCs is available [here](https://cloud.ibm.com/vpc-ext/network/vpcs)
SUBNET | The name of an EXISTING Subnet. The list of Subnets is available [here](https://cloud.ibm.com/vpc-ext/network/subnets). 
SECURITY_GROUP | The name of an EXISTING Security group. The list of Security Groups is available [here](https://cloud.ibm.com/vpc-ext/network/securityGroups). 
HOSTNAME | The Hostname for the HANA VSI. The hostname should be up to 13 characters as required by SAP.  For more information on rules regarding hostnames for SAP systems, check [SAP Note 611361: Hostnames of SAP ABAP Platform servers](https://launchpad.support.sap.com/#/notes/%20611361)
PROFILE | The instance profile used for the HANA VSI. The list of certified profiles for HANA VSIs is available [here](https://cloud.ibm.com/docs/sap?topic=sap-hana-iaas-offerings-profiles-intel-vs-vpc). <br> Details about all x86 instance profiles are available [here](https://cloud.ibm.com/docs/vpc?topic=vpc-profiles). <br>  For more information about supported DB/OS and IBM Gen 2 Virtual Server Instances (VSI), check [SAP Note 2927211: SAP Applications on IBM Virtual Private Cloud](https://launchpad.support.sap.com/#/notes/2927211) <br /> Default value: "mx2-16x128"
IMAGE | The OS image used for HANA VSI (See Obs*). A list of images is available [here](https://cloud.ibm.com/docs/vpc?topic=vpc-about-images).<br /> Default value: ibm-redhat-8-6-amd64-sap-hana-2

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
The password for the HANA system will be hidden during the schematics apply step and will not be available after the deployment.

- **Sensitive** - The variable value is not displayed in your Schematics logs and it is hidden in the input field.<br />
- The following parameters should have the same values as the ones set for the BASTION server: REGION, ZONE, VPC, SUBNET, SECURITYGROUP.
- For any manual change in the terraform code, you have to make sure that you use a certified image based on the SAP NOTE: 2927211.
- OS **image** for **DB VSI.** Supported OS images for DB VSIs: ibm-sles-15-3-amd64-sap-hana-2, ibm-sles-15-4-amd64-sap-hana-3, ibm-redhat-8-4-amd64-sap-hana-2, ibm-redhat-8-6-amd64-sap-hana-2.
    - The list of available VPC Operating Systems supported by SAP: SAP note '2927211 - SAP Applications on IBM Virtual Private Cloud (VPC) Infrastructure environment' https://launchpad.support.sap.com/#/notes/2927211; The list of all available OS images: https://cloud.ibm.com/docs/vpc?topic=vpc-about-images
    - Default variable:  DB_IMAGE = "ibm-redhat-8-6-amd64-sap-hana-2"
- OS **image** for **SAP APP VSI**. Supported OS images for APP VSIs: ibm-sles-15-3-amd64-sap-applications-2, ibm-sles-15-4-amd64-sap-applications-4, ibm-redhat-8-4-amd64-sap-applications-2, ibm-redhat-8-6-amd64-sap-applications-2. 
    - The list of available VPC Operating Systems supported by SAP: SAP note '2927211 - SAP Applications on IBM Virtual Private Cloud (VPC) Infrastructure environment' https://launchpad.support.sap.com/#/notes/2927211; The list of all available OS images: https://cloud.ibm.com/docs/vpc?topic=vpc-about-images
    - Default variable: APP_IMAGE = "ibm-redhat-8-6-amd64-sap-applications-2"
-  SAP **HANA Installation path kit**
     - Supported SAP HANA versions on RHEL8.4, RHEL8.6, SLES15.3 and SLES15.4: HANA 2.0 SP 5 Rev 57, kit file: 51055299.ZIP
     - Example for Red Hat 8 or Suse 15: KIT_SAPHANA_FILE = "/storage/HANADB/51055299.ZIP"
     - Default variable:  KIT_SAPHANA_FILE = "/storage/HANADB/51055299.ZIP"

## 2.1 Executing the deployment of **SAP HANA** in GUI (Schematics)

### IBM Cloud API Key
The IBM Cloud API Key should be provided as input value of type sensitive for "IBMCLOUD_API_KEY" variable, in `IBM Schematics -> Workspaces -> <Workspace name> -> Settings` menu.
The IBM Cloud API Key can be created [here](https://cloud.ibm.com/iam/apikeys).

### Input parameters

The following parameters can be set in the Schematics workspace: VPC, Subnet, Security group, Resource group, Hostname, Profile, Image, SSH Keys and your SAP system configuration variables. These are described in [General input variables Section](#15-general-input-variables) section.

Beside [General input variables Section](#15-general-input-variables), the below ones, in IBM Schematics have specific description and GUI input options:

**VSI input parameters:**

Parameter | Description
----------|------------
IBMCLOUD_API_KEY | IBM Cloud API key (Sensitive* value).
PRIVATE_SSH_KEY | Input your id_rsa private key pair content in OpenSSH format (Sensitive* value). This private key should be used only during the terraform provisioning and it is recommended to be changed after the SAP deployment.
ID_RSA_FILE_PATH | The file path for PRIVATE_SSH_KEY will be automatically generated by default. If it is changed, it must contain the relative path from git repo folders.<br /> Default value: "ansible/id_rsa".
BASTION_FLOATING_IP | The FLOATING IP from the Bastion Server.

**SAP input parameters:**

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
    select [Schematics](https://cloud.ibm.com/schematics/overview).
       - Click Create a workspace.
       - Enter a name for your workspace.
       - Click Create to create your workspace.
    2.  On the workspace **Settings** page, enter the URL of this solution in the Schematics examples Github repository.
     - Select the latest Terraform version.
     - Click **Save template information**.
     - In the **Input variables** section, review the default input variables and provide alternatives if desired.
    - Click **Save changes**.

4.  From the workspace **Settings** page, click **Generate plan** 
5.  Click **View log** to review the log files of your Terraform
    execution plan.
6.  Apply your Terraform template by clicking **Apply plan**.
7.  Review the log file to ensure that no errors occurred during the
    provisioning, modification, or deletion process.

The output of the Schematics Apply Plan will list the public/private IP addresses
of the VSI host, the hostname and the VPC.

## 2.2 Executing the deployment of **SAP HANA** in CLI

### IBM Cloud API Key
For the script configuration add your IBM Cloud API Key in terraform planning phase command 'terraform plan --out plan1'.
You can create an API Key [here](https://cloud.ibm.com/iam/apikeys).
 
### Input parameter file
The solution is configured by editing your variables in the file `input.auto.tfvars`
Edit your VPC, Subnet, Security group, Hostnames, Profile, Image, SSH Keys and starting with minimal recommended disk sizes like so:

**VSI input parameters**

```shell
##########################################################
# General VPC variables:
######################################################

REGION = "eu-de"
# Region for the VSI. Supported regions: https://cloud.ibm.com/docs/containers?topic=containers-regions-and-zones#zones-vpc
# Example: REGION = "eu-de"

ZONE = "eu-de-2"
# Availability zone for VSI. Supported zones: https://cloud.ibm.com/docs/containers?topic=containers-regions-and-zones#zones-vpc
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
# EXISTING Subnet in the same region and zone as the VSI, previously created by the user. The list of available Subnets: https://cloud.ibm.com/vpc-ext/network/subnets
# Example: SUBNET = "ic4sap-subnet"

SSH_KEYS = ["r010-57bfc315-f9e5-46bf-bf61-d87a24a9ce7a", "r010-e372fc6f-4aef-4bdf-ade6-c4b7c1ad61ca", "r010-09325e15-15be-474e-9b3b-21827b260717", "r010-5cfdb578-fc66-4bf7-967e-f5b4a8d03b89" , "r010-7b85d127-7493-4911-bdb7-61bf40d3c7d4", "r010-771e15dd-8081-4cca-8844-445a40e6a3b3", "r010-d941534b-1d30-474e-9494-c26a88d4cda3"]
# List of SSH Keys UUIDs that are allowed to SSH as root to the VSI. The SSH Keys should be created for the same region as the VSI. The list of available SSH Keys UUIDs: https://cloud.ibm.com/vpc-ext/compute/sshKeys
# Example: SSH_KEYS = ["r010-8f72b994-c17f-4500-af8f-d05680374t3c", "r011-8f72v884-c17f-4500-af8f-d05900374t3c"]

##########################################################
# DB VSI variables:
##########################################################

HOSTNAME = "saphanadb1"
# The Hostname for the DB VSI. The hostname should be up to 13 characters, as required by SAP
# Example: HOSTNAME = "ic4sap"

PROFILE = "mx2-16x128"
# The instance profile used for the HANA VSI. The list of certified profiles for HANA VSIs: https://cloud.ibm.com/docs/sap?topic=sap-hana-iaas-offerings-profiles-intel-vs-vpc
# Details about all x86 instance profiles: https://cloud.ibm.com/docs/vpc?topic=vpc-profiles).
# For more information about supported DB/OS and IBM Gen 2 Virtual Server Instances (VSI), check [SAP Note 2927211: SAP Applications on IBM Virtual Private Cloud](https://launchpad.support.sap.com/#/notes/2927211) 
# Default value: "mx2-16x128"

IMAGE = "ibm-redhat-8-6-amd64-sap-hana-2"
# OS image for HANA VSI. The following OS images for HANA VSIs are supported by the automation: ibm-sles-15-3-amd64-sap-hana-2, ibm-sles-15-4-amd64-sap-hana-3, ibm-redhat-8-4-amd64-sap-hana-2, ibm-redhat-6-6-amd64-sap-hana-3.
# Make sure the OS image is appropriate for the selected [VSI profil](https://cloud.ibm.com/docs/sap?topic=sap-hana-iaas-offerings-profiles-intel-vs-vpc#hana-iaas-intel-vs-vpc-)
# The list of available VPC Operating Systems supported by SAP: SAP note '2927211 - SAP Applications on IBM Virtual Private Cloud (VPC) Infrastructure environment' https://launchpad.support.sap.com/#/notes/2927211; The list of all available OS images: https://cloud.ibm.com/docs/vpc?topic=vpc-about-images
# Example: IMAGE = "ibm-sles-15-4-amd64-sap-hana-3" 
# Default value: "ibm-redhat-8-6-amd64-sap-hana-2" 
```

Edit your SAP system configuration variables that will be passed to the ansible automated deployment:

```shell
##########################################################
# SAP HANA configuration
##########################################################

hana_sid = "HDB"
# SAP HANA system ID. Should follow the SAP rules for SID naming.
# Example: hana_sid = "HDB"

hana_sysno = "00"
# SAP HANA instance number. Should follow the SAP rules for instance number naming.
# Example: hana_sysno = "01"

hana_system_usage = "custom"
# System usage. Default: custom. Suported values: production, test, development, custom
# Example: hana_system_usage = "custom"

hana_components = "server"
# SAP HANA Components. Default: server. Supported values: all, client, es, ets, lcapps, server, smartda, streaming, rdsync, xs, studio, afl, sca, sop, eml, rme, rtl, trp
# Example: hana_components = "server"

kit_saphana_file = "/storage/HANADB/51055299.ZIP"
# SAP HANA Installation kit path
# Supported SAP HANA versions on RHEL8 and SLES15: HANA 2.0 SP 5 Rev 57, kit file: 51055299.ZIP
# Example for RHEL8 or SLES15: kit_saphana_file = "/storage/HANADB/51055299.ZIP"
```

## Steps to reproduce:

For initializing terraform:

```shell
terraform init
```

For planning phase:

```shell
terraform plan --out plan1
# you will be asked for the following sensitive variables: 'IBMCLOUD_API_KEY'  and  'IBMCLOUD_API_KEY'.
```

For apply phase:

```shell
terraform apply
```

For destroy:

```shell
terraform destroy
# you will be asked for the following sensitive variables as a destroy confirmation phase:
'IBMCLOUD_API_KEY'  and  'IBMCLOUD_API_KEY'.
```

The Terraform version used for deployment should be >= 1.3.6. 
Note: The deployment was tested with Terraform 1.3.6

### 3.1 Related links:

- [How to create a BASTION/STORAGE VSI for SAP in IBM Schematics](https://github.com/IBM-Cloud/sap-bastion-setup)
- [Securely Access Remote Instances with a Bastion Host](https://www.ibm.com/cloud/blog/tutorial-securely-access-remote-instances-with-a-bastion-host)
- [VPNs for VPC overview: Site-to-site gateways and Client-to-site servers.](https://cloud.ibm.com/docs/vpc?topic=vpc-vpn-overview)
- [IBM Cloud Schematics](https://www.ibm.com/cloud/schematics)
