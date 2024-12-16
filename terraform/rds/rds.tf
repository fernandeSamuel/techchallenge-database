
# Security Group para permitir acesso ao RDS (porta 5432)
resource "aws_security_group" "rds_sg" {
  name        = "rds-public-access"
  description = "Security group para acesso ao PostgreSQL RDS"

  ingress {
    description = "Allow PostgreSQL access"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Permite acesso público (apenas para teste)
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Instância RDS PostgreSQL
resource "aws_db_instance" "techchallenge-rds" {
  allocated_storage      = 20
  engine                 = "postgres"
  engine_version         = "16.1"
  instance_class         = "db.t3.micro"
  db_name                = "techchallenge"
  username               = "master"
  password               = "password1234"
  publicly_accessible    = true
  skip_final_snapshot    = true
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
}

# Criar tabela e inserir 10 CPFs com local-exec
resource "null_resource" "create_table_and_insert_cpfs" {
  depends_on = [aws_db_instance.techchallenge_rds]

  provisioner "local-exec" {
    command = <<EOT
    PGPASSWORD="password1234" psql \
      --host=${aws_db_instance.techchallenge_rds.address} \
      --port=5432 \
      --username=master \
      --dbname=techchallenge \
      --command="
      CREATE TABLE IF NOT EXISTS clientes (
        id SERIAL PRIMARY KEY,
        cpf VARCHAR(11) NOT NULL UNIQUE
      );

      INSERT INTO clientes (cpf) VALUES
      ('12345678901'),
      ('23456789012'),
      ('34567890123'),
      ('45678901234'),
      ('56789012345'),
      ('67890123456'),
      ('78901234567'),
      ('89012345678'),
      ('90123456789'),
      ('01234567890');
      "
    EOT
  }
}
