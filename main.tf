module "vpc" {
  source = "./modules/vpc"

  name = "lesson-db-vpc"
  cidr = "10.0.0.0/16"

  azs = ["us-east-1a", "us-east-1b"]

  public_subnets  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnets = ["10.0.11.0/24", "10.0.12.0/24"]

  tags = {
    Project = "lesson-db-module"
    Env     = "dev"
  }
}

module "rds" {
  source = "./modules/rds"

  name       = "lesson-db"
  use_aurora = var.use_aurora

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnet_ids

  allowed_cidr_blocks = ["10.0.0.0/16"]

  engine         = var.engine
  engine_version = var.engine_version

  instance_class = var.instance_class
  multi_az       = var.multi_az

  database_name   = "appdb"
  master_username = "dbadmin"
  master_password = var.db_password

  tags = var.tags
}
