# Provedor PostgreSQL
terraform {
  required_providers {
    pg = {
      source  = "cyrilgdn/pg"
      version = "~> 1.0"
    }
  }
}

# Security Group para permitir acesso ao RDS (porta 5432)
resource "aws_security_group" "rds_sg" {
  name        = "rds-public-access"
  description = "Security group para acesso ao PostgreSQL RDS"

  ingress {
    description = "Allow PostgreSQL access"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Criação da instância RDS PostgreSQL
resource "aws_db_instance" "techchallenge_rds" {
  allocated_storage      = 20
  engine                 = "postgres"
  engine_version         = "16.1"
  instance_class         = "db.t3.micro"
  name                   = "techchallenge"
  username               = "master"
  password               = "password1234"
  publicly_accessible    = true
  skip_final_snapshot    = true
  db_subnet_group_name   = aws_db_subnet_group.rds_subnet_group.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
}

# Subnet Group para RDS
resource "aws_db_subnet_group" "rds_subnet_group" {
  name        = "rds-subnet-group"
  description = "Subnet group for RDS instance"
  subnet_ids  = ["subnet-xxxxxxxx", "subnet-yyyyyyyy"] # Substitua pelos IDs de subnets públicas
}

# Configuração do Provedor PostgreSQL
provider "pg" {
  host     = aws_db_instance.techchallenge_rds.address
  port     = 5432
  database = aws_db_instance.techchallenge_rds.name
  username = aws_db_instance.techchallenge_rds.username
  password = aws_db_instance.techchallenge_rds.password
  sslmode  = "disable"
}

# Criar a tabela 'clientes' com a coluna 'cpf'
resource "pg_exec" "create_table" {
  depends_on = [aws_db_instance.techchallenge_rds]

  queries = [
    <<EOT
    CREATE TABLE IF NOT EXISTS clientes (
      id SERIAL PRIMARY KEY,
      cpf VARCHAR(11) NOT NULL UNIQUE
    );
    EOT
  ]
}

# Inserir 10 valores aleatórios na tabela 'clientes'
resource "pg_exec" "insert_cpfs" {
  depends_on = [pg_exec.create_table]

  queries = [
    <<EOT
    INSERT INTO clientes (cpf) VALUES ('12345678901');
    INSERT INTO clientes (cpf) VALUES ('23456789012');
    INSERT INTO clientes (cpf) VALUES ('34567890123');
    INSERT INTO clientes (cpf) VALUES ('45678901234');
    INSERT INTO clientes (cpf) VALUES ('56789012345');
    INSERT INTO clientes (cpf) VALUES ('67890123456');
    INSERT INTO clientes (cpf) VALUES ('78901234567');
    INSERT INTO clientes (cpf) VALUES ('89012345678');
    INSERT INTO clientes (cpf) VALUES ('90123456789');
    INSERT INTO clientes (cpf) VALUES ('01234567890');
    EOT
  ]
}
