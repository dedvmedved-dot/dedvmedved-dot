# ЛР5 — Верификация кластера PostgreSQL с Patroni + etcd + HAProxy

**Статус**: ⚠️ Пройдена с 5 сквозными багами
**Дата**: 2026-06-25
**Стенд**: Proxmox pve 9.2.3, 7 ВМ (ID 401-403,411-413,421)

## Найденные проблемы

### 5 сквозных багов (как ЛР1-ЛР4)

1. 🔴 **Нет `clone` в main.tf** — книга не приводит код Terraform
2. 🔴 **`ansible_user=student` вместо `ubuntu`** — во всех группах inventory
3. 🔴 **`local-lvm`** в Terraform-примерах
4. 🟡 **`ANSIBLE_HOST_KEY_CHECKING=False`** — не упомянуто
5. 🟡 **`cicustom`** — не документирован

### Специфичные замечания ЛР5

6. 🟡 **4 ГБ RAM на узлах PostgreSQL** — может не хватить ресурсов на хосте (7 ВМ × 2-4 ГБ = минимум 18 ГБ)
7. 🟡 **`pip install patroni[etcd3]` требует PEP 668 bypass** на Ubuntu 24.04
8. 🟡 **PIP через `executable: pip3`** — модуль `pip` в Ansible требует `--break-system-packages` или virtualenv
9. 🟡 **`patroni_name` не передаётся в шаблон `patroni.yml.j2`** — в шаблоне есть `name: {{ patroni_name }}`, но переменная объявлена только в inventory
10. 🟢 **IP etcd-кластера в DCS захардкожены** — не масштабируется

## Архитектура

| Группа | ВМ | ID | IP | RAM |
|--------|----|----|----|-----|
| postgres | pg-01 | 401 | .151 | 4 ГБ |
| postgres | pg-02 | 402 | .152 | 4 ГБ |
| postgres | pg-03 | 403 | .153 | 4 ГБ |
| etcd | etcd-01 | 411 | .161 | 2 ГБ |
| etcd | etcd-02 | 412 | .162 | 2 ГБ |
| etcd | etcd-03 | 413 | .163 | 2 ГБ |
| haproxy | pg-lb-01 | 421 | .171 | 2 ГБ |

**Всего**: 20 ГБ RAM, 14 vCPU. На реальном стенде Proxmox с одним узлом может не хватить.

## Рекомендации

1. Исправить 5 сквозных багов (как в ЛР1)
2. Добавить предупреждение о потреблении ресурсов
3. Добавить virtualenv или `--break-system-packages` для pip
4. Указать, что `patroni_name` должен совпадать с именем узла в inventory
