resource "aws_db_instance" "techchallenge-rds" {
  allocated_storage        = 20
  engine                   = "postgres"
  engine_version           = "16.1"
  identifier               = "techchallenge-rds"
  instance_class           = "db.t3.micro"
  storage_encrypted        = false
  publicly_accessible      = false
  delete_automated_backups = true
  skip_final_snapshot      = true
  db_name                  = "techchallenge"
  username                 = "master"
  password                 = "0dG3y771"
  apply_immediately        = true
  multi_az                 = false

}
