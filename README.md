# Terraform Azure VM Configuration - Config-Virtual-Machine

## Project Overview
This Terraform configuration provisions a complete Windows Virtual Machine infrastructure on Microsoft Azure. It creates all the necessary networking components, security settings, and compute resources needed to run a Windows Server 2022 VM in Azure.

## What This Terraform Does

### Infrastructure Components Created

#### 1. **Resource Group**
- Creates a resource group named `tf-rg` in the `East US` region
- Tags: `environment = dev`, `project = terraform-demo`
- Serves as the container for all Azure resources

#### 2. **Virtual Network (VNet)**
- Creates a virtual network named `tf-vnet`
- Address space: `10.0.0.0/16`
- Enables communication between resources

#### 3. **Subnets**
- **Subnet 1** (`tf-subnet`): `10.0.1.0/24`
- **Subnet 2** (`tf-subnet2`): `10.0.2.0/24`
- Both subnets exist within the virtual network for resource segmentation

#### 4. **Network Security Group (NSG)**
- Creates a security group named `tf-nsg`
- Allows inbound SSH traffic on port 22 from any source (`0.0.0.0/0`)
- Associated with both subnets for network traffic control

#### 5. **Network Interface (NIC)**
- Creates a network interface (`tf-nic`)
- Connects the VM to the subnet
- Configured with dynamic private IP allocation
- Associated with a public IP for external access

#### 6. **Public IP Address**
- Creates a static public IP (`tfpub-ip`)
- Enables external access to the VM
- Static allocation ensures consistent IP address

#### 7. **Windows Virtual Machine**
- Creates a Windows Server 2022 Datacenter VM
- Configurable name (default: `TF-VMTEST`)
- Default size: `Standard_DS1_v2`
- Admin credentials configured via variables
- OS disk with `Standard_LRS` storage

#### 8. **Managed Disk**
- Creates a 1TB managed disk (`tf-managed-disk`)
- Data disk attached to the VM with `lun = 0`
- Set to read-only caching
- Provides additional storage capacity

## Files in This Configuration

| File | Purpose |
|------|---------|
| `main.tf` | Core resource definitions for all Azure resources |
| `variables.tf` | Input variable definitions (vm_name, credentials, size) |
| `local.tf` | Local values for network configuration and resource properties |
| `output.tf` | Output values (subnet ID, NIC ID, public IP ID) |
| `terraform.tfvars` | Variable values (test VM credentials and name) |
| `providers.tf` | Azure provider configuration (excluded from Git) |

## Prerequisites

- Azure subscription and credentials
- Terraform CLI installed (v1.0+)
- Azure CLI or service principal authentication configured

## How to Use

### 1. Initialize Terraform
```bash
terraform init
```
This downloads the required provider and prepares the working directory.

### 2. Plan Deployment
```bash
terraform plan -out=main.tfplan
```
This shows all resources that will be created.

### 3. Apply Configuration
```bash
terraform apply main.tfplan
```
This creates all resources in Azure.

### 4. Destroy Resources (Cleanup)
```bash
terraform destroy
```
This removes all created resources.

## Variables

- **vm_name**: Name of the Virtual Machine (default: `TF-VMTEST`)
- **admin_username**: Admin username for the VM (default: `azureuser`)
- **admin_password**: Admin password (marked as sensitive)
- **vm_size**: VM size (default: `Standard_DS1_v2`)

## Outputs

After applying, Terraform will output:
- `tf-subnet_id`: ID of the first subnet
- `tf-nic_id`: ID of the network interface
- `tfpub-ip_id`: ID of the public IP address

## Security Notes

⚠️ **This is a development configuration. For production:**
- Move credentials to Azure Key Vault
- Restrict SSH source IP from `*` to specific IPs
- Use managed identities for authentication
- Enable encryption at rest
- Implement Azure Policy for compliance

## Networking Architecture

```
Virtual Network (10.0.0.0/16)
├── Subnet 1 (10.0.1.0/24)
│   ├── Network Interface
│   │   └── Windows VM (Private IP)
│   └── NSG (Allow SSH)
├── Subnet 2 (10.0.2.0/24)
│   └── NSG (Allow SSH)
└── Public IP (Static)
    └── Assigned to NIC → VM
```

## Support

For more information, refer to the [Terraform Azure Provider Documentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)
