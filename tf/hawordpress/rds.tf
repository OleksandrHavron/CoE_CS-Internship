resource "aws_db_subnet_group" "education" {
  name       = local.name
  subnet_ids = module.vpc.database_subnets

  tags = {
    Name = "Education"
  }
}

module "db" {
  source  = "terraform-aws-modules/rds/aws"

  identifier = "${local.name}db"

  engine            = "mysql"
  engine_version    = "8.0.28"
  family = "mysql8.0"           # DB parameter group
  major_engine_version = "8.0"  # DB option group
  instance_class    = "db.t3.micro"
  storage_type = "gp2"
  allocated_storage = 5
  max_allocated_storage = 20


  db_name  = "${local.name}db"
  username = "user"
  port     = "3306"

  multi_az = true
  vpc_security_group_ids = [aws_security_group.rds.id]
  subnet_ids             = module.vpc.database_subnets
  db_subnet_group_name   = aws_db_subnet_group.education.name
  

  maintenance_window = "Mon:00:00-Mon:03:00"
  backup_window      = "03:00-06:00"

  backup_retention_period = 3
  skip_final_snapshot = true
  deletion_protection = false

  # Enhanced Monitoring - see example for details on how to create the role
  # by yourself, in case you don't want to create it automatically
  monitoring_interval = 60
  monitoring_role_name = "MyRDSMonitoringRole"
  create_monitoring_role = true

}
