provider "vsphere" {
  user                 = var.vsphere_user
  password             = var.vsphere_password
  vsphere_server       = var.vsphere_server
  allow_unverified_ssl = true
}

data "vsphere_datacenter" "dc" {
  name = var.datacenter
}

data "vsphere_datastore" "datastore" {
  name          = var.datastore
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_host" "host" {
  name          = var.host_name
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_network" "network" {
  name          = var.network
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_virtual_machine" "template" {
  name          = var.template_name
  datacenter_id = data.vsphere_datacenter.dc.id
}

resource "vsphere_virtual_machine" "vm" {
  name             = var.vm_name
  resource_pool_id = data.vsphere_host.host.resource_pool_id
  datastore_id     = data.vsphere_datastore.datastore.id
  firmware         = "efi"

  num_cpus = var.vm_cpu
  memory   = var.vm_memory
  guest_id = data.vsphere_virtual_machine.template.guest_id
  scsi_type = data.vsphere_virtual_machine.template.scsi_type

  network_interface {
    network_id   = data.vsphere_network.network.id
    adapter_type = data.vsphere_virtual_machine.template.network_interface_types[0]
  }

  disk {
    label            = "disk0"
    size             = var.vm_disk
    thin_provisioned = data.vsphere_virtual_machine.template.disks.0.thin_provisioned
  }

  clone {
    template_uuid = data.vsphere_virtual_machine.template.id

    customize {
      windows_options {
        computer_name         = var.vm_name
        admin_password        = var.admin_password
        auto_logon            = true
        auto_logon_count      = 1
        time_zone             = 004
      }

      network_interface {
        ipv4_address = var.vm_ip
        ipv4_netmask = 24
      }

      ipv4_gateway = var.vm_gateway
      dns_server_list = [var.dns_server]
    }
  }

  provisioner "remote-exec" {
    inline = [
      "powershell -Command \"Invoke-WebRequest -Uri https://installer.prometheus.ps1 -OutFile C:\\prometheus.ps1\"",
      "powershell -Command \"& C:\\prometheus.ps1\"",
      "powershell -Command \"Invoke-WebRequest -Uri https://installer.grafana.ps1 -OutFile C:\\grafana.ps1\"",
      "powershell -Command \"& C:\\grafana.ps1\""
    ]

    connection {
      type     = "winrm"
      host     = var.vm_ip
      user     = "Administrator"
      password = var.admin_password
    }
  }
}
