terraform {
  required_providers {
    vsphere = {
      source = "hashicorp/vsphere"
      version = "2.2.0"
    }
  }
}

# terraform {
#   required_providers {
#     remote = {
#       source = "tenstad/remote"
#       version = "0.1.0"
#     }
#   }
# }

# provider "remote" {
#   alias = "server1"

#   max_sessions = 2

#   conn {
#     host     = "10.0.0.12"
#     user     = "john"
#     password = "password"
#     sudo     = true
#   }
# }

provider "vsphere" {
  user                 = var.vsphere_user
  password             = var.vsphere_password
  vsphere_server       = var.vsphere_server
  allow_unverified_ssl = true
}

data "vsphere_datacenter" "datacenter" {
  name = var.VMDatacenter
}

data "vsphere_datastore" "datastore" {
  name          = var.VMCommon.Datastore
  datacenter_id = data.vsphere_datacenter.datacenter.id
}


# ----- Need to figure out how to make this conditional
# data "vsphere_compute_cluster" "cluster" {
#   name          = var.VMCluster
#   datacenter_id = data.vsphere_datacenter.datacenter.id
# }

# data "vsphere_resource_pool" "pool" {
#   name = var.VMCluster ? "${var.VMCluster}/Resources" : data.vsphere_compute_cluster.cluster.resource_pool_id
#   datacenter_id = data.vsphere_datacenter.datacenter.id
# }

# ----- https://github.com/hashicorp/terraform-provider-vsphere/issues/262
data "vsphere_resource_pool" "pool" {
    name =  "Resources" 
    datacenter_id = data.vsphere_datacenter.datacenter.id
  }

data "vsphere_network" "network" {
  name          = var.VMCommon.Network
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

data "vsphere_virtual_machine" "template" {
  name          =var.VMCommon.Template
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

resource "vsphere_virtual_machine" "vm" {

  for_each = {for vm in var.VMs: vm.Name => vm if vm.K3sRole == var.Role}

  name             = each.value.Name
  resource_pool_id = data.vsphere_resource_pool.pool.id
  datastore_id     = data.vsphere_datastore.datastore.id
  folder           = each.value.Folder
  num_cpus         = each.value.CPU
  memory           = each.value.RAM
  guest_id         = data.vsphere_virtual_machine.template.guest_id
  scsi_type        = data.vsphere_virtual_machine.template.scsi_type
  network_interface {
    network_id   = data.vsphere_network.network.id
    adapter_type = data.vsphere_virtual_machine.template.network_interface_types[0]
  }
  disk {
    label            = "disk0"
    size             = data.vsphere_virtual_machine.template.disks.0.size
    thin_provisioned = data.vsphere_virtual_machine.template.disks.0.thin_provisioned
  }
  clone {
    template_uuid = data.vsphere_virtual_machine.template.id
    
    customize {
      linux_options {
        host_name = each.value.Name
        domain    = each.value.Domain
      }

      network_interface {
      }
    }
  }

  connection {
    type = "ssh"
    user = var.AdminAcct
    password = var.AdminPW
    host = self.default_ip_address
  }

  provisioner "file" {
    source = "${path.module}\\ConfigScripts\\install.sh"
    destination = "/tmp/install.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/install.sh" ,
      "/tmp/install.sh ${var.AdminAcct} ${var.AdminPW} ${var.RHEL_Sub_user} ${var.RHEL_Sub_PW} ${each.value.K3sRole} ${index(var.VMs,each.value)} ${var.K3STOKEN}"  # ${vsphere_virtual_machine.vm}"
    ]
  }

  # # setup SSH with keys.  K3sup requires this
  # provisioner "file" {
  #   source = "${var.SSHKeyPath}.pub"
  #   destination = "/home/${var.AdminAcct}/.ssh/authorized_keys"
  # }

  # # install K3s
  # # https://github.com/alexellis/k3sup/blob/master/README.md#caveats-on-security
  # provisioner "local-exec" {
  #   command = <<EOT
  #           k3sup install --ip ${self.default_ip_address} --context k3s --user ${var.AdminAcct}
  #       EOT
  # }

  # # k3sup install --ip ${self.default_ip_address} --context k3s --ssh-key ${var.SSHKeyPath} --user $(whoami)
}