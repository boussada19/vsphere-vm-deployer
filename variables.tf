variable "vsphere_user" {
  type        = string
  description = "Nom d'utilisateur vSphere"
  default     = "administrator@vsphere.local"
}

variable "vsphere_password" {
  type        = string
  description = "Mot de passe vSphere"
  sensitive   = true
  default     = "y#1>hwAsr%r,sx1"
}

variable "vsphere_server" {
  type        = string
  description = "Adresse IP ou nom DNS du vCenter Server"
  default     = "10.0.1.50"
}
