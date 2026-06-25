1|terraform {
2|  required_version = ">= 1.6.0"
3|
4|  required_providers {
5|    proxmox = {
6|      source  = "bpg/proxmox"
7|      version = "~> 0.70"
8|    }
9|  }
10|}
11|
12|provider "proxmox" {
13|  endpoint  = var.proxmox_endpoint
14|  api_token = var.proxmox_api_token
15|  insecure  = true
16|}
17|
18|locals {
19|  ssh_public_key = trimspace(file(pathexpand(var.ssh_public_key_path)))
20|}
21|
22|resource "proxmox_virtual_environment_vm" "web01" {
23|  name        = var.vm_name
24|  description = "Lab 1 VM created by OpenTofu"
25|  tags        = ["iac-course", "lab01", "tofu"]
26|
27|  node_name = var.proxmox_node_name
28|  vm_id     = var.vm_id
29|
30|  started = true
31|
32|  # CRITICAL FIX: clone from cloud-init template
33|  clone {
34|    vm_id = 9000
35|  }
36|
37|  cpu {
38|    cores = 2
39|    type  = "host"
40|  }
41|
42|  memory {
43|    dedicated = 2048
44|  }
45|
46|  network_device {
47|    bridge = "vmbr0"
48|  }
49|
50|  disk {
51|    datastore_id = var.datastore_id
52|    interface    = "scsi0"
53|    size         = 20
54|    file_format  = "raw"
55|  }
56|
57|  initialization {
58|    datastore_id = var.datastore_id
59|
60|    ip_config {
61|      ipv4 {
62|        address = var.vm_ip
63|        gateway = var.vm_gateway
64|      }
65|    }
66|
67|    user_account {
68|      username = var.vm_user
69|      keys     = [local.ssh_public_key]
70|    }
71|  }
72|
73|  operating_system {
74|    type = "l26"
75|  }
76|
77|  agent {
78|    enabled = true
79|  }
80|}