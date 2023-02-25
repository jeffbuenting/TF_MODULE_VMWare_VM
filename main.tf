# terraform {
#   required_providers {
#     vsphere = {
#       source  = "hashicorp/vsphere"
#       version = "2.2.0"
#     }
#   }
# }

# provider "vsphere" {
#   user                 = var.vsphere_user
#   password             = var.vsphere_password
#   vsphere_server       = var.vsphere_server
#   allow_unverified_ssl = true
# }

data "vsphere_datacenter" "datacenter" {
  name = var.VMDatacenter
}

data "vsphere_datastore" "datastore" {
  name          = var.VMDatastore
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
  name          = "Resources"
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

data "vsphere_network" "network" {
  name          = var.vmnetwork
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

data "vsphere_virtual_machine" "template" {
  name          = var.vmtemplate
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

# data template_file "metadataconfig" {
#   template = file(var.vmmetadata)
#   vars = {
#     hostname = var.vmname
#   }
# }

resource "vsphere_virtual_machine" "vm" {
  name             = var.vmname
  resource_pool_id = data.vsphere_resource_pool.pool.id
  datastore_id     = data.vsphere_datastore.datastore.id
  folder           = var.vmfolder
  num_cpus         = var.num_cpus
  memory           = var.ram
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
  }

  extra_config = {
    "guestinfo.metadata"          = base64encode(var.vmmetadata)
    "guestinfo.metadata.encoding" = "base64"
    "guestinfo.userdata"          = base64encode(var.vmuser_data)
    "guestinfo.userdata.encoding" = "base64"
  }
}
