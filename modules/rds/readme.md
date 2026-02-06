# RDS Module (RDS or Aurora)

Універсальний Terraform-модуль, який створює:

- `use_aurora=false` → одну RDS instance (PostgreSQL або MySQL)
- `use_aurora=true` → Aurora cluster + writer instance (Aurora PostgreSQL або Aurora MySQL)

В обох випадках модуль автоматично створює:

- DB Subnet Group
- Security Group
- Parameter Group (для RDS) або Cluster Parameter Group (для Aurora)
- Базові параметри: `max_connections` + логування + пам’ять (Postgres напряму, MySQL — з мапінгом)

---

## Приклад використання

### RDS PostgreSQL (звичайна інстанса)

```hcl
module "rds" {
  source = "./modules/rds"

  name       = "app"
  use_aurora = false

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnet_ids

  allowed_cidr_blocks = ["10.0.0.0/16"]

  engine         = "postgres"
  engine_version = "15.4"
  instance_class = "db.t3.medium"
  multi_az       = true

  database_name    = "appdb"
  master_username  = "dbadmin"
  master_password  = var.db_password

  tags = {
    Project = "lesson-db-module"
    Env     = "dev"
  }
}
Aurora PostgreSQL
module "aurora" {
  source = "./modules/rds"

  name       = "app"
  use_aurora = true

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnet_ids

  allowed_cidr_blocks = ["10.0.0.0/16"]

  engine         = "aurora-postgresql"
  engine_version = "15.4"
  instance_class = "db.r6g.large"

  database_name    = "appdb"
  master_username  = "dbadmin"
  master_password  = var.db_password
}
Змінні
name (string, required) — базова назва ресурсів

use_aurora (bool, default=false) — перемикає RDS/Aurora

vpc_id (string, required) — VPC ID

subnet_ids (list(string), required) — приватні підмережі (мін. 2)

allowed_cidr_blocks (list(string), default=[]) — дозволені CIDR до DB порту

allowed_security_group_ids (list(string), default=[]) — дозволені SG до DB порту

engine (string, required) — postgres|mysql|aurora-postgresql|aurora-mysql

engine_version (string, default="") — версія engine

instance_class (string, default="db.t3.medium")

multi_az (bool, default=false) — тільки для RDS instance

allocated_storage (number, default=20) — тільки для RDS instance

storage_type (string, default="gp3") — тільки для RDS instance

database_name (string, default="appdb")

master_username (string, default="dbadmin")

master_password (string, required, sensitive) — пароль (не комітити в git)

port (number, default=0) — 0 = auto (5432/3306)

max_connections (number, default=200)

log_statement (string, default="ddl") — Postgres; для MySQL мапиться на general_log=1

work_mem (string, default="4096") — Postgres; для MySQL мапиться на tmp_table_size

Як змінити тип БД / engine / клас інстансу
RDS PostgreSQL: use_aurora=false, engine="postgres"

RDS MySQL: use_aurora=false, engine="mysql"

Aurora PostgreSQL: use_aurora=true, engine="aurora-postgresql"

Aurora MySQL: use_aurora=true, engine="aurora-mysql"

Клас інстансу задається змінною instance_class.
```
