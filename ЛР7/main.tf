terraform {
  required_version = ">= 1.6.0"
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "~> 0.70"
    }
  }
}

provider "proxmox" {
  endpoint  = var.proxmox_endpoint
  api_token = var.proxmox_api_token
  insecure  = true
}

locals {
  ssh_key = trimspace(file(pathexpand(var.ssh_public_key_path)))
  vms = {
    "pxc1" = { id = 507, ip = "192.168.0.171/24", cores = 2, mem = 4096, disk = 30 }
    "pxc2" = { id = 508, ip = "192.168.0.172/24", cores = 2, mem = 4096, disk = 30 }
    "pxc3" = { id = 509, ip = "192.168.0.173/24", cores = 2, mem = 4096, disk = 30 }
  }
}

resource "proxmox_virtual_environment_vm" "ЛР7" {
  for_each = local.vms

  name      = each.key
  node_name = var.proxmox_node_name
  vm_id     = each.value.id
  started   = true

  cpu {
    cores = each.value.cores
  }

  memory {
    dedicated = each.value.mem
  }

  network_device {
    bridge = "vmbr0"
  }

  disk {
    datastore_id = var.datastore_id
    interface    = "scsi0"
    size         = each.value.disk
  }

  agent {
    enabled = true
  }

  operating_system {
    type = "l26"
  }

  clone {
    vm_id = var.template_vm_id
    full  = true
  }

  initialization {
    datastore_id = var.datastore_id
    ip_config {
      ipv4 {
        address = each.value.ip
        gateway = var.gateway
      }
    }
user_account {
  keys     = [local.ssh_key]
  username = var.vm_user
}
  }
}
