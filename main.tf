provider "vsphere" {
  user           = var.vsphere_user
  password       = var.vsphere_password
  vsphere_server = var.vsphere_server
  allow_unverified_ssl = true
}

# 1. Data sources
data "vsphere_datacenter" "dc" {
  name = "AUTO-INFRA"
}

data "vsphere_datastore" "datastore" {
  name          = "datastore1"
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_network" "network" {
  name          = "ESXi-VM-Network"
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_host" "host" {
  name          = "10.1.1.10" # Adaptez si nécessaire
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_virtual_machine" "template" {
  name          = "Clonage-VM" # Nom exact de votre template
  datacenter_id = data.vsphere_datacenter.dc.id
}

# 2. Clonage avec personnalisation
resource "vsphere_virtual_machine" "vm" {
  name             = "win-cloned-custom"
  resource_pool_id = data.vsphere_host.host.resource_pool_id
  datastore_id     = data.vsphere_datastore.datastore.id

  num_cpus  = 2
  memory    = 2048
  firmware  = "efi"  # Vérifiez que le modèle utilise EFI, sinon changez à "bios"
  guest_id  = data.vsphere_virtual_machine.template.guest_id
  scsi_type = data.vsphere_virtual_machine.template.scsi_type

  network_interface {
    network_id   = data.vsphere_network.network.id
   # adapter_type = data.vsphere_virtual_machine.template.network_interface_types[0]
  }

  disk {
    label            = "disk0"
    size             = 40
    thin_provisioned = data.vsphere_virtual_machine.template.disks[0].thin_provisioned
  }

  clone {
    template_uuid = data.vsphere_virtual_machine.template.id
    customize {
      windows_options {
        computer_name    = "wincloned"
        admin_password   = "TESTTEST123@"
        workgroup        = "WORKGROUP"
        time_zone        = 4  # UTC+1 (France/Tunisie)
        auto_logon       = true
        auto_logon_count = 1
      }

      network_interface {
        ipv4_address = "10.0.1.85"
        ipv4_netmask = 24
      }

      ipv4_gateway    = "10.0.1.1"
      dns_server_list = ["10.0.1.70"]
    }
  }
    extra_config = { 
           "ethernet0.startConnected" = "TRUE" 
 }
}
