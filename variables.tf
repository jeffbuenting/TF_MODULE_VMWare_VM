variable vsphere_user {
    description = "vCenter User"
    type = string
}

variable vsphere_password {
    description = "vCenter User password."
    type = string
}

variable vsphere_server {
    description = "vCenter Server"
    type = string
}

variable VMDatacenter {
    description = "VM Datacenter"
    type = string
}

variable ISODatastore {
    description = "Datastore that contains the ISO files"
    type = string
}

# ----- With a standalone single node VMWare cluster use the host name / IP for the Cluster Name
variable VMCluster {
    description = "vCenter Cluster"
    type = string
}

# ----- VM Settings
variable VMCommon {
    type = map
}

variable VMs {
    description = "VM Configs"
    type = list(object({
        Name=string,
        Domain=string,
        Folder=string,
        CPU=number,
        RAM=number,
        K3sRole=string
    }))
}

variable "AdminAcct" {
    type = string
}

variable "AdminPW" {
    type = string
}

variable "RHEL_Sub_user" {
    type = string
}

variable "RHEL_Sub_PW" {
    type = string
}

variable "Role" {
    type = string
}

variable "K3STOKEN" {
    type = string
}