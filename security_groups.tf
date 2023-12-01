# Criando o Security group para o Load Balancer
resource "aws_security_group" "securityGroupLoad" {
    name        = "securityGroupLoad"
    description = "Security Group para a LoadBalancer"

    vpc_id      = aws_vpc.VPC-oficial.id 
    ingress { 
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
    description = "Security group para as instancias ec2    "
    vpc_id = aws_vpc.VPC-oficial.id

    ingress {
        description = "Allow remote access to app"
        from_port = "8080"
        to_port = "8080"
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
    tags = {
      Name = "security-ec2"
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
    security_groups = [aws_security_group.app.id]
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