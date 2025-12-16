variable "vm_name" {
  description = "The name of the Virtual Machine"
  type        = string
}
variable "admin_username" {
    description = "Enter the Admin Username"
    type =string
}
variable "admin_password" {
    description = "Enter the Admin Password"
    type =string
    sensitive = true
}
variable "vm_size" {
    description = "The size of the Virtual Machine"
    type        = string
    default = "Standard_DS1_v2"
}