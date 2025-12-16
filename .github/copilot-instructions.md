# Terraform Azure VM Configuration 
## Project Overview
This Terraform configuration provisions a Windows Virtual Machine on Azure with networking infrastructure. The setup demonstrates IaC patterns for Azure resources including VNets, subnets, network interfaces, and security groups.

## Architecture & Components

**Key Azure Resources:**
- **Resource Group** (`tf-rg`): East US region, tagged for dev/terraform-demo
- **Virtual Network** (`tf-vnet`): 10.0.0.0/16, managed via `locals`
- **Subnets** (2x): `tf-subnet` (10.0.1.0/24) and `tf-subnet2` (10.0.2.0/24)
- **Network Security**: NSG with SSH inbound rule (port 22), associated to both subnets
- **Compute**: Windows Server 2022 VM with public IP and managed disk (1TB)

**Data Flow Pattern:**
Values flow from `terraform.tfvars` → `variables.tf` (vm_name, admin credentials, size) → `local.tf` (networking constants) → `main.tf` (resource instantiation) → `output.tf` (key IDs for downstream use)

## File Organization & Patterns

| File | Purpose | Key Pattern |
|------|---------|------------|
| `providers.tf` | Azure provider config (v4.5.0) | Service principal auth with hardcoded IDs (⚠️ security issue—use env vars/secrets) |
| `local.tf` | Centralized network configuration | All subnets/addressing defined here; reused in `main.tf` |
| `variables.tf` | Input variables | VM name, admin creds (sensitive flag), VM size with default |
| `main.tf` | Resource definitions | Resource names hardcoded with `tf-` prefix convention |
| `output.tf` | Export values | Exports subnet/NIC/IP IDs for external reference |
| `terraform.tfvars` | Variable values | Sensitive creds stored in plain text (development only) |

## Developer Workflows

**Terraform Workflow:**
```bash
# Validate syntax and dependencies
terraform validate

# Preview infrastructure changes
terraform plan -out=main.tfplan

# Apply configuration (output: main.tfplan, terraform.tfstate updated)
terraform apply

# Destroy all resources
terraform destroy
```

**State Management:**
- State files tracked locally: `terraform.tfstate` (current) + `.tfstate.backup` (previous)
- No remote state configured; plan files commitable but state files should be in .gitignore

## Naming & Conventions

- **Resource Prefix**: `tf-` (e.g., `tf-rg`, `tf-vnet`, `tf-nic`)
- **Locals Usage**: Network configs centralized in `local.tf`; reference via `local.resource_location`, `local.subnets[0]`
- **Variable Names**: Snake_case (`vm_name`, `admin_username`)
- **Output Names**: Descriptive with resource type (`tf-subnet_id`, `tfpub-ip_id`)

## Critical Implementation Notes

1. **Hardcoded Values**: Resource group name (`tf-rg`), location (`East US`), VM size default (`Standard_DS1_v2`) are fixed—consider parameterizing if multi-environment support needed

2. **Networking Pattern**: Subnets defined in `locals` as array, referenced individually as separate `azurerm_subnet` resources. Both subnets get identical NSG rules via associations

3. **Security Config**: SSH allowed from `*` source (0.0.0.0/0)—tighten for production. Windows VM uses `azurerm_windows_virtual_machine` (not generic), requiring Windows-specific image

4. **Public IP Strategy**: Static allocation for NIC to ensure consistent endpoint access

5. **Managed Disk**: Separate 1TB disk created but not attached to VM—requires `azurerm_virtual_machine_data_disk_attachment` resource

## Common Tasks for AI Agents

**Adding a resource:** Follow `resource "azurerm_TYPE" "tf-name" { ... }` pattern; reference locals where applicable

**Modifying NSG rules:** Edit security_rule blocks in `azurerm_network_security_group.tf-nsg`; consider extracting to dynamic blocks for scalability

**Changing VM config:** Update `variables.tf` for user inputs, pass to resource via `var.*` references; OS image details in `source_image_reference` block

**Exporting values:** Add `output "descriptive-name" { value = resource.id }` to `output.tf`

## Security & State Considerations

⚠️ **Development-Only Setup:**
- Credentials exposed in `providers.tf` and `terraform.tfvars`
- State files unencrypted and local
- SSH open to Internet (0.0.0.0/0)

For production: Use Azure Key Vault, Azure DevOps/GitHub Actions secrets, remote state (Azure Storage + encryption), and restrict NSG source IPs.

## External Dependencies

- **Provider**: HashiCorp azurerm v4.5.0, azuread (version unspecified—pin for consistency)
- **Azure Subscription**: Credentials reference specific subscription/tenant via hardcoded IDs
- **Resource Naming**: Check Azure naming conventions for length/character limits if scaling
