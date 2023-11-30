# Criação do instância no RDS
resource "aws_db_instance" "database" {
  allocated_storage     = 20
  storage_type          = "gp2"
  engine                = "mysql"
  engine_version        = "5.7"
  instance_class        = "db.t2.micro"
  
  username              =  var.db_username
  password              =  var.db_password
  
  parameter_group_name  = "default.mysql5.7"
  vpc_security_group_ids = [aws_security_group.rds.id]

  db_subnet_group_name    = aws_db_subnet_group.aws_db_subnet_group.name
  
  identifier            = "instancia-database-rds"
  publicly_accessible   = false
  skip_final_snapshot   = true
  multi_az              = true 


  tags = {
    Name = "database aplicacao"
  }
}

