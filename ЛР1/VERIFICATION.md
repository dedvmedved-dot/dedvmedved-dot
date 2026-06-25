# ЛР1 — Верификация Terraform/OpenTofu + первая ВМ в Proxmox

**Статус**: ⚠️ Пройдена с исправлениями (3 критических бага)
**Дата**: 2026-06-25
**Стенд**: Proxmox pve 9.2.3, root@192.168.0.200, OpenTofu 1.9.1, provider bpg/proxmox 0.70.0

## Результат проверки

ЛР1 развёрнута практически: создан API-токен Proxmox, cloud-init шаблон (VMID 9000, ubuntu-2404-template), ВМ web-01 (VMID 105) создана через OpenTofu, проверен ping, SSH, cloud-init.

**Итог**: концепция верна, но main.tf в книге содержит 3 ошибки, без которых развёртывание невозможно.

## Обнаруженные ошибки

| № | Степень | Расположение | Описание | Исправление |
|---|---------|-------------|----------|-------------|
| 1 | КРИТИЧЕСКАЯ | main.tf (шаг 7) | Отсутствует блок `clone { vm_id = 9000 }`. Без него provider не знает, из какого шаблона/образа клонировать ВМ. `terraform apply` упадёт с ошибкой. | Добавить блок `clone { vm_id = 9000 }` перед `cpu {}` |
| 2 | ВЫСОКАЯ | main.tf (шаг 7) | `datastore_id = "local-lvm"` — хранилище с таким именем не существует в типовой установке Proxmox 8+. На стенде: `vm-storage` (zfs). | Заменить на актуальное имя хранилища (на стенде `vm-storage`) |
| 3 | СРЕДНЯЯ | main.tf (шаг 7), раздел 1.6.9 | Раздел 1.6.9 текстом описывает необходимость cloud-init шаблона, но код main.tf не содержит ни `clone`, ни команды создания шаблона. Студент не сможет выполнить лабораторную. | Добавить в практическую часть шаг «Создание cloud-init шаблона» с командами `qm create ... importdisk ... template` |
| 4 | СРЕДНЯЯ | Неявная | При клонировании ВМ из шаблона с настроенным `cicustom` (cloud-init snippets), Terraform-настройки SSH-ключей могут быть переопределены сниппетом. На стенде потребовалось `qm set 105 --delete cicustom`. | Документировать: шаблон НЕ должен иметь `cicustom`, либо Terraform должен очищать его в `initialization` |
| 5 | НИЗКАЯ | main.tf | Версия провайдера `~> 0.70`. Минимальная доступная: 0.69.0. Рекомендуется `>= 0.70.0` для совместимости. | Уточнить минимальную версию |
| 6 | НИЗКАЯ | terraform.tfvars.example | IP Proxmox `192.168.0.10:8006` — в реальном стенде может отличаться (на тестовом `192.168.0.200:8006`) | Оставить как пример, добавить примечание |

## Исправленный main.tf (рабочий)

```hcl
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
  ssh_public_key = trimspace(file(pathexpand(var.ssh_public_key_path)))
}

resource "proxmox_virtual_environment_vm" "web01" {
  name        = var.vm_name
  description = "Lab 1 VM created by Terraform/OpenTofu"
  tags        = ["iac-course", "lab01", "terraform"]

  node_name = var.proxmox_node_name
  vm_id     = var.vm_id

  started = true

  # КРИТИЧЕСКОЕ ИСПРАВЛЕНИЕ: клонирование из cloud-init шаблона
  clone {
    vm_id = 9000   # ID шаблона в Proxmox
  }

  cpu {
    cores = 2
    type  = "host"
  }

  memory {
    dedicated = 2048
  }

  network_device {
    bridge = "vmbr0"
  }

  disk {
    datastore_id = "vm-storage"   # имя хранилища в вашем Proxmox
    interface    = "scsi0"
    size         = 20
    file_format  = "raw"
  }

  initialization {
    datastore_id = "vm-storage"

    ip_config {
      ipv4 {
        address = var.vm_ip
        gateway = var.vm_gateway
      }
    }

    user_account {
      username = var.vm_user
      keys     = [local.ssh_public_key]
    }
  }

  operating_system {
    type = "l26"
  }

  agent {
    enabled = true
  }
}
```

## Создание cloud-init шаблона (перед terraform apply)

```bash
# На Proxmox (root):
qm create 9000 --name ubuntu-2404-template --memory 2048 --cores 2 --net0 virtio,bridge=vmbr0
qm importdisk 9000 /var/lib/vz/template/iso/ubuntu-24.04-server-cloudimg-amd64.img vm-storage
qm set 9000 --scsihw virtio-scsi-pci --scsi0 vm-storage:vm-9000-disk-0
qm set 9000 --ide2 vm-storage:cloudinit
qm set 9000 --boot c --bootdisk scsi0
qm set 9000 --serial0 socket --vga serial0
qm set 9000 --agent enabled=1
qm template 9000
```

## Результаты тестового развёртывания

| Параметр | Значение |
|----------|----------|
| VM ID | 105 |
| Имя | web-01 |
| CPU | 2 cores (host) |
| RAM | 2048 MB |
| Диск | 20 GB (vm-storage, raw) |
| Сеть | vmbr0, IP 192.168.0.101/24 |
| Cloud-init | done |
| SSH | успешно (ed25519 ключ) |
| Время создания | ~60 сек |
| Время удаления | ~5 сек |

## Рекомендации автору

1. **Обязательно**: добавить блок `clone { vm_id = NNNN }` в main.tf (ошибка №1)
2. **Обязательно**: заменить `local-lvm` на обобщённое описание с примечанием «уточните имя хранилища в вашем Proxmox: Datacenter → Storage» (ошибка №2)
3. **Желательно**: добавить в практическую часть явный шаг создания cloud-init шаблона с полными командами (ошибка №3)
4. **Желательно**: добавить примечание про `cicustom` и его влияние на cloud-init (ошибка №4)
5. Остальные файлы (variables.tf, outputs.tf, .gitignore) — без ошибок
