# Исправленные лабораторные работы (IAC-курс)

Результат верификации 12 глав книги. Все 5 сквозных багов исправлены.

## Исправленные баги

### 1. ✅ clone в main.tf
Добавлен во все 12 глав:
```hcl
clone {
  vm_id = var.template_vm_id
  full  = true
}
```

### 2. ✅ ansible_user=ubuntu
Везде заменён `student` на `ubuntu` (облачный образ Ubuntu).

### 3. ✅ datastore_id параметризован
Вместо жёсткого `local-lvm` — переменная `var.datastore_id` с умолчанием `vm-storage`.

### 4. ✅ cicustom очищен
Шаблон VMID 9000 очищен от `cicustom`. Cloud-init работает без помех.
Если клонируете чужой шаблон — выполните:
```bash
qm set <TEMPLATE_VMID> --delete cicustom
```

### 5. ✅ ANSIBLE_HOST_KEY_CHECKING=False
Для первого подключения Ansible к новым ВМ:
```bash
ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i inventory.ini playbook.yml
```

## Структура репозитория

```
ЛР0/ — Подготовка окружения
ЛР1/ — Terraform: первая ВМ (main.tf + variables.tf)
ЛР2/ — Ansible (inventory.ini + playbook.yml)
ЛР3/ — Nginx + Flask + PostgreSQL (3 ВМ)
ЛР4/ — HAProxy + Keepalived + VIP (4 ВМ)
ЛР5/ — Patroni + etcd + HAProxy (7 ВМ)
ЛР6/ — ELK/OpenSearch + Kafka KRaft (5 ВМ)
ЛР7/ — Percona XtraDB Cluster (3 ВМ)
ЛР8/ — Consul Service Discovery (5 ВМ)
ЛР9/ — Proxmox + Terraform/OpenTofu (N ВМ)
ЛР10/ — Kubernetes + Velero (4 ВМ)
Приложение_Г/ — GFS2 + iSCSI (4 ВМ)
```

## Быстрый старт

```bash
export TF_CLI_CONFIG_FILE=~/.tofurc
cd ЛР1/
tofu init && tofu apply -auto-approve
```

## Ограничения стенда

- VM ID 110 — ВМ ассистента, не трогать
- VM ID 202-206 — k8s-кластер, не трогать
- Все новые ВМ используют ID вне этих диапазонов
