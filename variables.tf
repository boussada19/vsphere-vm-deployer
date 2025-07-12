variable "vsphere_user" {}
variable "vsphere_password" { sensitive = true }
variable "vsphere_server" {}

variable "datacenter" {}
variable "datastore" {}
variable "host_name" {}
variable "network" {}
variable "template_name" {}

variable "vm_name" {}
variable "vm_cpu" {}
variable "vm_memory" {}
variable "vm_disk" {}

variable "vm_ip" {}
variable "vm_gateway" {}
variable "dns_server" {}
variable "admin_password" {}
