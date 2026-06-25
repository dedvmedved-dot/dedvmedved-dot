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
20|
21|  vms = {
22|    web = {
23|      name   = "web-01"
24|      vm_id  = 201
25|      ip     = "192.168.0.101/24"
26|      cores  = 2
27|      memory = 2048
28|      role   = "web"
29|    }
30|
31|    app = {
32|      name   = "app-01"
33|      vm_id  = 211
34|      ip     = "192.168.0.111/24"
35|      cores  = 2
36|      memory = 2048
37|      role   = "app"
38|    }
39|
40|    db = {
41|      name   = "db-01"
42|      vm_id  = 221
43|      ip     = "192.168.0.121/24"
44|      cores  = 2
45|      memory = 3072
46|      role   = "db"
47|    }
48|  }
49|}
50|
51|resource "proxmox_virtual_environment_vm" "lab03" {
52|  for_each = local.vms
53|
54|  name        = each.value.name
55|  description = "Lab 03 ${each.value.role} VM"
56|  tags        = ["iac-course", "lab03", each.value.role]
57|
58|  node_name = var.proxmox_node_name
59|  vm_id     = each.value.vm_id
60|
61|  started = true
62|
63|  # КЛЮЧЕВОЕ ИСПРАВЛЕНИЕ: clone из шаблона
64|  clone {
65|    vm_id = 9000
66|    full  = true
67|  }
68|
69|  cpu {
70|    cores = each.value.cores
71|    type  = "host"
72|  }
73|
74|  memory {
75|    dedicated = each.value.memory
76|  }
77|
78|  network_device {
79|    bridge = "vmbr0"
80|  }
81|
82|  disk {
83|    datastore_id = var.datastore_id
84|    interface    = "scsi0"
85|    size         = 20
86|  }
87|
88|  initialization {
89|    datastore_id = var.datastore_id
90|
91|    ip_config {
92|      ipv4 {
93|        address = each.value.ip
94|        gateway = var.gateway
95|      }
96|    }
97|
98|    user_account {
99|      username = var.vm_user
100|      keys     = [local.ssh_public_key]
101|    }
102|  }
103|
104|  operating_system {
105|    type = "l26"
106|  }
107|
108|  agent {
109|    enabled = true
110|  }
111|}
112|