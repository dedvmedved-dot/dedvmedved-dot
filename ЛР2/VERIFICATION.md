# ЛР2 — Верификация Ansible

**Статус**: ⚠️ Пройдена с 1 критическим замечанием
**Дата**: 2026-06-25
**Стенд**: Ubuntu 24.04 VM (web-01, 192.168.0.101), Ansible 2.21.1

## Результат проверки

Все 14 шагов пройдены успешно: ping, установка Nginx, копирование HTML, шаблон конфигурации, handler, controlled failure (config drift → восстановление).

### Найденные проблемы

#### 1. 🔴 CRITICAL: Несовпадение пользователя (ЛР1 ↔ ЛР2)

| Где | Пользователь |
|-----|-------------|
| ЛР1 cloud-init | `ubuntu` |
| ЛР2 inventory.ini | `ansible_user=student` |

**Причина**: Ubuntu cloud-image по умолчанию создаёт пользователя `ubuntu`. В `main.tf` (ЛР1) указано `vm_user = "ubuntu"`, но ЛР2 ожидает `student`.

**Исправление (2 варианта)**:
- Вариант A (рекомендуемый): в ЛР1 заменить `vm_user = "student"`, для cloud-image потребуется user-data cloud-init, создающий учётную запись `student`
- Вариант B: в ЛР2 inventory.ini использовать `ansible_user=ubuntu`

В тестовом прогоне использован вариант B.

#### 2. 🟡 MEDIUM: ANSIBLE_HOST_KEY_CHECKING не упоминается

При первом подключении SSH выдаёт предупреждение о новом host key. Ansible по умолчанию использует strict host key checking, что приводит к `UNREACHABLE`.

**Исправление**: добавить в инструкцию:
```bash
export ANSIBLE_HOST_KEY_CHECKING=False
```
или `-e ansible_ssh_common_args='-o StrictHostKeyChecking=no'` в inventory.

#### 3. 🟢 LOW: Неиспользуемые переменные

В `group_vars/web.yml` определены:
```yaml
nginx_index_title: "..."
nginx_index_message: "..."
```
Но файл `files/index.html` статический, эти переменные никогда не используются. Это может запутать студента.

**Исправление**: либо удалить неиспользуемые переменные, либо сделать `index.html` шаблоном.

#### 4. 🟢 LOW: Установка Ansible (PEP 668)

Команда `sudo apt install ansible` работает на старых дистрибутивах, но на Ubuntu 24.04+ может потребоваться:
```bash
pip install --user --break-system-packages ansible
```

## Результаты тестового прогона

```
PLAY RECAP: ok=10  changed=7  failed=0
Повторный:     ok=9   changed=0  (идемпотентно)
curl:          200 OK, HTML корректный
Controlled failure: config drift обнаружен и исправлен (changed=2)
```

## Рекомендация

Согласовать имя пользователя между ЛР1 и ЛР2. Рекомендуемый подход:
1. В ЛР1: создать cloud-init user-data, создающий пользователя `student` с sudo без пароля
2. В ЛР2: inventory.ini остаётся с `ansible_user=student`
