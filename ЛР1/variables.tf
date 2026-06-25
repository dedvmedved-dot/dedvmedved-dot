variable "proxmox_endpoint" {
  description = "Proxmox API endpoint"
  type        = string
}

variable "proxmox_api_token" {
  description = "Proxmox API token"
  type        = string
  sensitive   = true
}

variable "proxmox_node_name" {
  description = "Proxmox node name"
  type        = string
  default     = "pve"
}

variable "vm_id" {
  description = "Virtual machine ID"
  type        = number
  default     = 101
}

variable "vm_name" {
  description = "Virtual machine name"
  type        = string
  default     = "web-01"
}

variable "vm_user" {
  description = "Default user inside VM"
  type        = string
  default     = "ubuntu"
}

variable "vm_ip" {
  description = "Static IP address of the VM"
  type        = string
  default     = "192.168.0.101/24"
}

variable "vm_gateway" {
  description = "Default gateway"
  type        = string
  default     = "192.168.0.1"
}

variable "ssh_public_key_path" {
  description = "Path to SSH public key"
  type        = string
  default     = "~/.ssh/id_ed25519.pub"
}