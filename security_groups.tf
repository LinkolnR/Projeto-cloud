# Criando o Security group para o Load Balancer
resource "aws_security_group" "securityGroupLoad" {
    name        = "securityGroupLoad"
    description = "Security Group para a LoadBalancer"

    vpc_id      = aws_vpc.VPC-oficial.id  # AJEITAR 

    ingress { # VERIFICAR TUDO ISSO
        description     = "Permitindo o trafico http"
        from_port       = "80"
        to_port         = "80"
        protocol        = "tcp"
        cidr_blocks     = ["0.0.0.0/0"] 
    }

    ingress { 
        description     = "Permitindo o conexao na porta 8080"
        from_port       = "8080"
        to_port         = "8080"
        protocol        = "tcp"
        cidr_blocks     = ["0.0.0.0/0"] 
    }

    ingress { 
        description     = "Permitindo o ssh com o computador"
        from_port       = "22"
        to_port         = "22"
        protocol        = "tcp"
        cidr_blocks     = ["0.0.0.0/0"] 
    }

    egress {
        description = "Permitindo a saida"
        from_port   = 0 
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]  
    }

    tags = {
        Name = "securityGroupLoad"
    }
  
}

# Criando security group para a aplicação
resource "aws_security_group" "app" {
    name = "app"
    description = "App server that use fast api and sql alchemy"
    vpc_id = aws_vpc.VPC-oficial.id

    ingress {
        description = "Allow remote access to app"
        from_port = "80"
        to_port = "80"
        protocol = "tcp"
        security_groups = [aws_security_group.securityGroupLoad.id] 
    }

    egress {
        description = "Allow acess to MySQL database"
        from_port = "0"
        to_port = "0"
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}
# Criando o security group para a 
resource "aws_security_group" "db" {
    name = "db"
    description = "MySQL database"
    vpc_id = aws_vpc.VPC-oficial.id

    ingress {
        description = "Allow acess to MySQL database"
        from_port = "3306"
        to_port = "3306"
        protocol = "tcp"
        cidr_blocks = [var.subnets_publicas[0], var.subnets_publicas[1]]
    }
    egress {
        description = "Allow acess to MySQL database"
        from_port = "0"
        to_port = "0"
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

# Grupo de Segurança para RDS
resource "aws_security_group" "rds" {
  name        = "grupo_rds"
  description = "RDS Security Group"

  vpc_id      = aws_vpc.VPC-oficial.id
  
  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/24","10.0.1.0/24"]  # Permitir apenas a instância EC2 específica
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Grupo para o rds"
  }
}