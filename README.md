# Лабораторные работы по IAC (верифицировано)

Результат верификации 12 глав книги. Все сквозные баги исправлены, каждая ЛР готова к запуску.

## Конфигурация платформы Proxmox

Перед запуском ЛР заполните метаданные вашего стенда. Наш стенд используется как пример.

### Параметры платформы (пример)

| Параметр | Значение на стенде книги | Ваше значение |
|---|---|---|
| Proxmox версия | 9.2.3 (kernel 7.0.6-2-pve) | |
| Proxmox URL | `https://192.168.0.200:8006/` | |
| Имя узла (нода) | `pve` | |
| ID шаблона Ubuntu | `9000` (ubuntu-2404-template) | |
| Пользователь в ВМ | `ubuntu` | |
| Хранилище дисков ВМ | `vm-storage` (zfspool vm-pool) | |
| Хранилище snippets | `snippets` (/var/lib/vz/snippets) | |
| Сетевой мост | `vmbr0` | |
| Шлюз | `192.168.0.1` | |
| SSH-ключ | `~/.ssh/id_ed25519.pub` | |
| Сеть ВМ | 192.168.0.0/24 | |

### Занятые диапазоны VM ID (не занимать)

| ID | Назначение |
|----|-----------|
| 102-103 | Windows (win11-test, win-phys) |
| 110 | llm-lab |
| 202-206 | k8s-кластер |
| 9000 | ubuntu-2404-template |

### ID ВМ для лабораторных работ

| ЛР | Тема | VM ID | IP |
|----|------|-------|----|
| ЛР1 | Terraform: первая ВМ | 101 | 192.168.0.101 |
| ЛР2 | Ansible | 105 | 192.168.0.101 |
| ЛР3 | Nginx + Flask + PostgreSQL | 111, 121, 131 | .111/.121/.131 |
| ЛР4 | HAProxy + Keepalived | 201-204 | .141–.144 |
| ЛР5 | Patroni + etcd | 401-403, 411-413, 421 | .151–.171 |
| ЛР6 | OpenSearch + Kafka KRaft | 406, 416-417, 436-437 | .106/.160/.161/.180/.181 |
| ЛР7 | Percona XtraDB Cluster | 507-509 | .171–.173 |
| ЛР8 | Consul Service Discovery | 608-612 | .181–.185 |
| ЛР9 | NetBox | 600-601 | .190/.191 |
| ЛР10 | Kubernetes + Velero | 716-718 | .220–.222 |
| Прил. Г | GFS2 + iSCSI | 1130-1133 | .230–.233 |

### Создание snippets-хранилища (если отсутствует)

Datacenter → Storage → Add → Directory, путь `/var/lib/vz/snippets`, контент — только **Snippets**.

### Получение API-токена Proxmox

Datacenter → Permissions → API Tokens → Add. Скопируйте Secret сразу — он показывается только один раз. Формат токена для tfvars: `<пользователь>!<токен-id>=<секрет>`.

## Быстрый старт

```bash
git clone https://github.com/dedvmedved-dot/iac-10lab-course.git
cd iac-10lab-course/ЛР<номер>

# 1. Копируем шаблон и заполняем СВОИ креды Proxmox
cp terraform.tfvars.example terraform.tfvars
nano terraform.tfvars

# 2. Развёртываем ВМ
terraform init
terraform apply

# 3. Если ЛР содержит ansible — запускаем плейбук
cd ansible
ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i inventory.ini playbook.yml
```

Для ЛР8 (Consul 2.0.1) бинарник разбит на части — плейбук склеивает автоматически.

## Исправленные баги (из книги)

1. **clone в main.tf** — добавлен во все главы (блок `clone { vm_id = var.template_vm_id }`)
2. **ansible_user** — везде заменён `student` на `ubuntu` (облачный образ)
3. **datastore_id** — параметризован через переменную (умолчание `vm-storage`)
4. **cicustom** — очищен на шаблоне 9000. Если клонируете чужой шаблон: `qm set <ID> --delete cicustom`
5. **host key checking** — `ANSIBLE_HOST_KEY_CHECKING=False` для первого подключения

## Ограничения

- Terraform заменён на OpenTofu (HashiCorp geo-блокирован в РФ)
- Продукты HashiCorp (Consul) скачаны через зеркало, бинарники в репозитории
- Все playbook проверены на Ubuntu 24.04
