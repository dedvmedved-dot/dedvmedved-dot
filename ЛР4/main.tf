terraform {
  required_version = ">= 1.6.0"
  required_providers {
    proxmox = { source = "bpg/proxmox", version = "~> 0.70" }
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
    lb = {
      name  = "lb-01"
      id    = 140
      ip    = "192.168.0.140/24"
      cores = 2
      mem   = 2048
    }
    web1 = {
      name  = "web-01"
      id    = 141
      ip    = "192.168.0.141/24"
      cores = 2
      mem   = 2048
    }
    web2 = {
      name  = "web-02"
      id    = 142
      ip    = "192.168.0.142/24"
      cores = 2
      mem   = 2048
    }
  }
}

resource "proxmox_virtual_environment_vm" "lab04" {
  for_each = local.vms

  name        = each.value.name
  description = "ЛР4 HA/VIP ${each.key}"
  tags        = ["iac-course", "lab04"]
  node_name   = "pve"
  vm_id       = each.value.id
  started     = true

  clone {
    vm_id = 9000
    full  = true
  }

  cpu {
    cores = each.value.cores
    type  = "host"
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
    size         = 20
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
      username = var.vm_user
      keys     = [local.ssh_key]
    }
  }

  operating_system {
    type = "l26"
  }

  agent {
    enabled = true
  }
}
