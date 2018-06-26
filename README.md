# Barracuda CloudGen Firewall and Web Application Firewall - Blue / Green deployment

## Introduction
Since the begining of time people have tried to automate tasks. Also in computer sience we have seen this from the early days. One limition was the infrastructure that needed to be in place for automation to commence. With virtualisation and public cloud this automation has come full circle and we can now deploy, manage, redeploy everything using automation techniques. We can descibe the operating environment in code, validate it, test it, document it and deploy it from a code repository. 

This is a giant change compared to the typical laborious deployment of infrastructure through cli, web ui, client or other. 

The purpose of this demo is to showcase how you can create, configure and secure your whole environment from code.

![CGF Azure Network Architecture](images/cudalab-blue-green.png)

## Prerequisites
The tools used in this setup are HashiCorp Terraform (> 0.11.x) and RedHat Ansible (> 2.x). Both tools have their pro's and con's. Working together they help maintaining the state of your infrastructure and the ensures the configuration is correct. The deployment can be done from either a bash shell script or from any CI tool. In our case we used Visual Studio Team Services (VSTS). The LINUX VSTS agent requires the Ansible and Terraform tools to be installed as well as the VSTS agent.

## Deployed resources
Following resources will be created by this deployment per color:
- One virtual network with CGF, WAF, WEB and SQL subnets
- Routing for the WEB and SQL subnets
- One CGF virtual machine with a network interface and public IP in a Availability Set
- One WAF virtual machine with a network interface and public IP in a Availability Set
- One WEB Linux virtual machine with a network interface
- One SQL Linux virtual machine with a network interface
- Two external Azure Basic Load Balanceris containing either the CGF or WAF virtual machines with a public IP and services for HTTP, HTTPS IPSEC and/or TINA VPN tunnels available
- Azure Traffic Manager to switch from Blue to Green deployment and back

## Launching the Template

The package provides a deploy.sh and destroy.sh scripts that will take your through the whole deployment. This can be peformed from the CLI or integrated with VSTS or another CI/CD tool. For VSTS you can find the build templates in the vsts directory. 

## Parameters
The script requires certain environment variables as well as some arguments. 

### Environment Variables

| Parameter Name | Description
|---|---
BACKEND_ARM_ACCESS_KEY | Azure Storage Access Key for the Terraform state file
BACKEND_STORAGE_ACCOUNT_NAME | Azure Storage Account Name for the Terraform state file
BACKEND_CONTAINER_NAME | Azure Storage Container Name for the Terraform state file
BACKEND_KEY_COLOR | Azure Storage File Name of the Terraform state file
BACKEND_KEY_TM | Azure Storage File Name of the Terraform state file for the Traffic Manager deployment
CCSECRET | identifying prefix for all VM's being build. e.g WeProd would become WeProd-VM-CGF (Max 19 char, no spaces, [A-Za-z0-9]
vNetResourceGroup | Resource Group that contains the VNET where the CGF will be installed in
vNetName | The name of the VNET where the CGF will be installed in
subnetNameCGF | The name of the subnet where CGF will be installed
subnetPrefixCGF | Network range of the Subnet containing the CloudGen Firewall (e.g. 172.16.136.0/24)
imageSKU | SKU Hourly (PAYG) or BYOL (Bring your own license)
vmSize | Size of the VMs to be created
fwVMAddressA | Static IP Address of the first CGF VM in Azure
fwVMAddressB | Static IP Address of the second CGF VM in Azure
ccManaged | Is this instance managed via a CloudGen Control Center (Yes/No)
ccClusterName | The name of the cluster of this instance in the CloudGen Control Center
ccRangeId | The range location of this instance in the CloudGen Control Center
ccIpAddress | IP address of the CloudGen Control Center
ccSecret | Secret to retrieve the configuration from the CloudGen Control Center


## Additional Resources