1|terraform {
2|  required_version = ">= 1.6.0"
3|  required_providers {
4|    proxmox = { source = "bpg/proxmox", version = "~> 0.70" }
5|  }
6|}
7|provider "proxmox" {
8|  endpoint  = var.proxmox_endpoint
9|  api_token = var.proxmox_api_token
10|  insecure  = true
11|}
12|
13|resource "proxmox_virtual_environment_vm" "lab04" {
14|  for_each = local.vms
15|
16|  name        = each.value.name
17|  description = "ЛР4 HA/VIP ${each.key}"
18|  tags        = ["iac-course", "lab04"]
19|  node_name   = "pve"
20|  vm_id       = each.value.id
21|  started     = true
22|
23|  clone {
24|    vm_id = 9000
25|    full  = true
26|  }
27|
28|  cpu {
29|    cores = each.value.cores
30|    type  = "host"
31|  }
32|
33|  memory {
34|    dedicated = each.value.mem
35|  }
36|
37|  network_device {
38|    bridge = "vmbr0"
39|  }
40|
41|  disk {
42|    datastore_id = var.datastore_id
43|    interface    = "scsi0"
44|    size         = 20
45|  }
46|
47|  initialization {
48|    datastore_id = var.datastore_id
49|    ip_config {
50|      ipv4 {
51|        address = each.value.ip
52|        gateway = var.gateway
53|      }
54|    }
55|    user_account {
56|      username = var.vm_user
57|      keys     = [local.ssh_key]
58|    }
59|  }
60|
61|  operating_system {
62|    type = "l26"
63|  }
64|
65|  agent {
66|    enabled = true
67|  }
68|}
69|