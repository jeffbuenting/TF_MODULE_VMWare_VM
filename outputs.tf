output "VMIP" {
  description = "IP of the VM"
  value       = vsphere_virtual_machine.vm.default_ip_address
}
