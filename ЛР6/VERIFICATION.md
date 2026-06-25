# ЛР6 — Верификация централизованного сбора логов (ELK/OpenSearch + Kafka KRaft)

**Статус**: ⚠️ Пройдена (без деплоя — сквозные баги)
**Дата**: 2026-06-25

## 5 сквозных багов (как ЛР1-ЛР5)

Те же: clone, student, local-lvm, ANSIBLE_HOST_KEY_CHECKING, cicustom.

## Специфичные замечания

6. 🟡 **5 ВМ** (log-client01, kafka01, logstash01, search01, dashboard01) — 12 ГБ RAM минимум
7. 🟡 **Kafka KRaft mode** — нужен Java JRE/JDK
8. 🟡 **OpenSearch** — отдельный репозиторий, не из стандартных Ubuntu
9. 🟡 **Filebeat на клиенте** — репозиторий Elastic/OpenSearch
10. 🟢 Упрощённый вариант (1 ВМ вместо 5) описан, но без main.tf
