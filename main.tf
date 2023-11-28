provider "aws" {
  region = "us-east-1"  # Substitua pela sua região desejada
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0.0"
    }
  }
  required_version = ">= 1.6.0"
}



data "aws_ami" "ubuntu"{
    most_recent = "true"

    filter{
        name = "name"
        values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
    }

    filter {
      name      = "virtualization-type"
      values    = ["hvm"] 
    }   

    owners = ["099720109477"]
}
# Criando o VPC 
resource "aws_vpc" "VPC-oficial" {
    // Setando cidr para o vpc
    cidr_block          = var.vpc_cidr_block
    // vamos habilitar o DNS 
    enable_dns_hostnames = false
    // colocando a tag para vpc
    tags = {
      Name = "VPC-oficial"
    } 
}
# Criando Gateway
resource "aws_internet_gateway" "internet-gateway-load-balancer" {
    // pegando o id do vpc 
    vpc_id = aws_vpc.VPC-oficial.id

    tags = {
      Name = "internet-gateway-load-balancer"
    }
}
# configurar as SubNets
data "aws_availability_zones" "available"{
    state = "available"
}
# Criando as subnets
resource "aws_subnet" "subnet-oficial" {
    # número de subnets públicas
    count       = 2
    # colocando a subnets na VPC
    vpc_id      = aws_vpc.VPC-oficial.id
    // associando a um CIDR 
    cidr_block = var.subnets[count.index]

    map_public_ip_on_launch = true
    
    // Pegando as zonas de disponibilidade
    availability_zone = data.aws_availability_zones.available.names[count.index]

    tags = {
        Name = "subnet-official-${count.index}"
    }
}
# Criando mais uma subnet pora o RDS 
resource "aws_subnet" "subnet-rds" {
    # colocando a subnets na VPC
    vpc_id      = aws_vpc.VPC-oficial.id
    // associando a um CIDR 
    cidr_block = var.subnets[3]

    map_public_ip_on_launch = true
    
    // Pegando as zonas de disponibilidade
    availability_zone = data.aws_availability_zones.available.names[3]

    tags = {
        Name = "subnet-rds"
    }
}


# Criando a tabela de rotas
resource "aws_route_table" "rota-load-official" {
      vpc_id = aws_vpc.VPC-oficial.id
      
      route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.internet-gateway-load-balancer.id
      }

  tags = {
    Name = "rota-load-official"
  }

}
# Associando as subnets na tabela de rotas
resource "aws_route_table_association" "subnetAssociation" {

    count           = 2

    route_table_id  = aws_route_table.rota-load-official.id  
    subnet_id       = aws_subnet.subnet-oficial[count.index].id
  
}
# Criando o Security group
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
# Criando um Target group
resource "aws_lb_target_group" "novo-target" {
  name        = "novo-target"
  port        = 8080
  protocol    = "HTTP"
  vpc_id      = aws_vpc.VPC-oficial.id  

  health_check {
    path                = "/"
    port                = 8080
    protocol            = "HTTP"
    interval            = 30
    timeout             = 10
    unhealthy_threshold = 2
  }
}
# Criando um Load Balancer
resource "aws_lb" "load-balancer" {
  name               = "load-balancer"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.securityGroupLoad.id]  # Substitua pelo ID do seu Security Group
  subnets            = aws_subnet.subnet-oficial[*].id      # Substitua pelo ID da sua Subnet

  enable_deletion_protection         = false
  enable_cross_zone_load_balancing   = true
  enable_http2                      = true
}
# Associando o Target Group ao Load Balancer
resource "aws_lb_listener" "example_listener" {
  load_balancer_arn = aws_lb.load-balancer.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.novo-target.arn
  }
}


resource "aws_instance" "load_balancer_off" {
      # Números de Instâncias 
      count     = 2
      # Pegando a imagem que queremos
      ami       = data.aws_ami.ubuntu.id
      # Tipo da intancia
      instance_type = "t2.micro" 
      #
      subnet_id = aws_subnet.subnet-oficial[count.index].id 

      key_name = "proj_link"

      vpc_security_group_ids = [ aws_security_group.securityGroupLoad.id ] 
    # Rodar dentro da máquina
    user_data = base64encode(<<-EOF
              #!/bin/bash
              sudo apt-get update
              sudo apt-get install pip -y
              pip install flask
              cd /home/ubuntu
              git clone https://github.com/LinkolnR/api_p_cloud_testes
              cd api_p_cloud_testes/
              python3 app.py
              EOF
              )


    tags = {
        Name = "load_balancer_off_${count.index}"
    }
}


resource "aws_lb_target_group_attachment" "example_target_group_attachment" {
  count           = length(aws_instance.load_balancer_off)
  target_group_arn = aws_lb_target_group.novo-target.arn
  target_id       = aws_instance.load_balancer_off[count.index].id
}

# Criação do Security Group no RDS
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

  db_subnet_group_name    = aws_db_subnet_group.subnet_group_new_vpc.name
  
  identifier            = "instancia-database-rds"
  publicly_accessible   = false
  skip_final_snapshot   = true
  multi_az              = true 


  tags = {
    Name = "database aplicacao"
  }
}


# Subnet Group para a nova VPC
resource "aws_db_subnet_group" "subnet_group_new_vpc" {
  name       = "db-subnet-group-new-vpc"
  subnet_ids = [aws_subnet.subnet-oficial[0].id,aws_subnet.subnet-oficial[1].id ,aws_subnet.subnet-rds.id] # Substitua pelos IDs das subnets da nova VPC
}

# data "aws_secretsmanager_secret" "db_credentials" {
#   name = "app/mysql/credentials"
# }

# data "aws_secretsmanager_secret_version" "current" {
#   secret_id = data.aws_secretsmanager_secret.db_credentials.id
# }

# locals {
#   db_credentials = jsondecode(data.aws_secretsmanager_secret_version.current.secret_string)
# }

