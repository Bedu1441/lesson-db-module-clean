# lesson-db-module — Terraform DB Module (RDS / Aurora)

Цей репозиторій містить універсальний Terraform-модуль **modules/rds**, який вміє створювати:

- **RDS instance** (PostgreSQL / MySQL) якщо `use_aurora = false`
- **Aurora Cluster + writer instance** (наприклад Aurora PostgreSQL) якщо `use_aurora = true`

В обох випадках модуль автоматично створює:

- **DB Subnet Group**
- **Security Group**
- **Parameter Group** (для RDS) або **Cluster Parameter Group** (для Aurora)
- базові параметри: `max_connections`, `log_statement`, `work_mem`

> Важливо: приклади RDS і Aurora потрібно запускати в **різних Terraform state**, щоб вони не видаляли ресурси один одного.
> Найпростіший спосіб — **Terraform workspaces** (описано нижче).

---

## Структура

```

.
├── main.tf
├── providers.tf
├── variables.tf
├── outputs.tf
├── backend.tf
├── modules/
│   ├── vpc/
│   └── rds/
└── examples/
├── rds-postgres/
│   └── terraform.tfvars
└── aurora-postgres/
└── terraform.tfvars

```

---

## Швидкий старт

### 0) Передумови

- Terraform встановлено
- AWS credentials налаштовані (AWS CLI або env змінні)
- Регіон: `us-east-1` (або змінити в providers.tf)

### 1) Ініціалізація

```powershell
terraform init -upgrade
terraform validate
```

### 2) Створити два workspace (RDS і Aurora)

```powershell
terraform workspace new rds
terraform workspace new aurora
```

---

## Сценарій 1 — RDS (PostgreSQL) `use_aurora = false`

### Plan

```powershell
terraform workspace select rds
terraform plan -var-file .\examples\rds-postgres\terraform.tfvars
```

### Apply (якщо потрібно створити реально)

```powershell
terraform workspace select rds
terraform apply -var-file .\examples\rds-postgres\terraform.tfvars
```

---

## Сценарій 2 — Aurora PostgreSQL `use_aurora = true`

### Plan

```powershell
terraform workspace select aurora
terraform plan -var-file .\examples\aurora-postgres\terraform.tfvars
```

### Apply (якщо потрібно створити реально)

```powershell
terraform workspace select aurora
terraform apply -var-file .\examples\aurora-postgres\terraform.tfvars
```

---

## Destroy (видалення ресурсів)

> Увага: видаляти треба окремо для кожного workspace.

### Destroy RDS

```powershell
terraform workspace select rds
terraform destroy -var-file .\examples\rds-postgres\terraform.tfvars
```

### Destroy Aurora

```powershell
terraform workspace select aurora
terraform destroy -var-file .\examples\aurora-postgres\terraform.tfvars
```

---

## Приклад використання модуля

Файл `main.tf` (короткий приклад ідеї):

```hcl
module "vpc" {
  source = "./modules/vpc"
  # ... inputs
}

module "rds" {
  source = "./modules/rds"

  use_aurora     = false
  engine         = "postgres"
  engine_version = "15.8"
  instance_class = "db.t3.medium"
  multi_az       = false

  vpc_id             = module.vpc.vpc_id
  subnet_ids  = module.vpc.subnet_ids
  allowed_cidr_blocks = ["10.0.0.0/16"]

  database_name = "appdb"
  db_username   = "dbadmin"
  master_password   = var.master_password
}
```

---

## Змінні модуля `modules/rds`

Нижче опис ключових змінних (повний список у `modules/rds/variables.tf`).

### Загальні

- `use_aurora` (bool) — `true` створює Aurora cluster, `false` створює RDS instance
- `engine` (string) — наприклад `postgres`, `mysql`, `aurora-postgresql`
- `engine_version` (string) — версія engine (наприклад `15.8`)
- `instance_class` (string) — клас інстансу (наприклад `db.t3.medium`)
- `multi_az` (bool) — Multi-AZ для RDS (для Aurora не використовується так само)

### Мережа

- `vpc_id` (string) — VPC де створюємо ресурси
- `subnet_ids` (list(string)) — приватні сабнети для DB subnet group
- `allowed_cidr_blocks` (list(string)) — CIDR, які матимуть доступ до DB по 5432/3306 (залежить від порту)

### DB креденшели

- `database_name` (string) — назва БД (наприклад `appdb`)
- `db_username` (string) — master username (наприклад `dbadmin`)
- `master_password` (string, sensitive) — master password (це НЕ AWS access key)

---

## Outputs

### Для обох сценаріїв:

- `db_subnet_group_name`
- `database_name`
- `endpoint`
- `port`
- `security_group_id`

### Для Aurora додатково:

- `reader_endpoint`
- `cluster_parameter_group_name`

### Для RDS додатково:

- `parameter_group_name`

> Повний список у `modules/rds/outputs.tf` та `outputs.tf` у root.

---

## Нотатки по підключенню до БД

За замовчуванням база створюється **в приватних сабнетах**, тому:

- з локального ПК підключення НЕ працюватиме (це нормально)
- підключення робиться з EC2 в тому ж VPC або через VPN / Bastion

---

Verification

Модуль було перевірено у двох режимах:
створення звичайної RDS instance (PostgreSQL) та Aurora Cluster.

Для перевірки використовувалися команди
terraform init,
terraform validate та
terraform plan з відповідними файлами змінних (examples/rds-postgres/terraform.tfvars і examples/aurora-postgres/terraform.tfvars). У режимі use_aurora = false створюється лише aws_db_instance разом із DB Subnet Group, Security Group та Parameter Group, без ресурсів Aurora.

У режимі use_aurora = true створюється aws_rds_cluster, writer-інстанс та cluster parameter group, без звичайної RDS instance.
Це підтверджує коректну роботу умовної логіки та універсальність модуля.
