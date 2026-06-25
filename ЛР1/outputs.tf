output "vm_name" {
  description = "Created VM name"
  value       = proxmox_virtual_environment_vm.web01.name
}

output "vm_id" {
  description = "Created VM ID"
  value       = proxmox_virtual_environment_vm.web01.vm_id
}

output "vm_ip" {
  description = "Configured VM IP address"
  value       = var.vm_ip
}

output "ssh_command" {
  description = "SSH command for connecting to VM"
  value       = "ssh ${var.vm_user}@${replace(var.vm_ip, "/24", "")}"
}