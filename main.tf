
terraform {
  required_providers {
    aws = {
        source = "hashicorp/aws"
        version = "~> 4.0.0"
    }
  }
}

// configurações da aws
provider "aws" {
    region = var.aws_region
}

data "aws_availability_zones" "available"{
    state = "available"
}

// TALVEZ DEPOIS DAQUI DE PRA SEPARAR EM MODULOS
// configurações da vpc
resource "aws_vpc" "tutorial_vpc" {
    // Setando cidr para o vpc
    cidr_block          = var.vpc_cidr_block
    // vamos habilitar o DNS 
    enable_dns_hostnames = true 
    // colocando a tag para vpc
    tags = {
      Name = "tutorial_vpc"
    } 
}
// Criando o gateway 

resource "aws_internet_gateway" "net_gateway" {
    // pegando o id do vpc 
    vpc_id = aws_vpc.tutorial_vpc.id

    tags = {
      Name = "net_gateway"
    }
}

// Criando As subnets 

resource "aws_subnet" "publics_subsnets" {
    // número de subnets públicas
    count       = var.subnet_count.public
    // colocando a subnets na VPC
    vpc_id      = aws_vpc.tutorial_vpc.id
  
    // associando a um CIDR 
    cidr_block = var.public_subnet_cidr_blocks[count.index]
    
    // Pegando as zonas de disponibilidade
    availability_zone = data.aws_availability_zones.available.names[count.index]

    tags = {
        Name = "subnet_publica_${count.index}"
    }
}

resource "aws_subnet" "privadas_subnets" {
    // número de subnets públicas
    count       = var.subnet_count.private
    // colocando a subnets na VPC
    vpc_id      = aws_vpc.tutorial_vpc.id
  
    // associando a um CIDR 
    cidr_block = var.private_subnet_cidr_blocks[count.index]
    
    // Pegando as zonas de disponibilidade
    availability_zone = data.aws_availability_zones.available.names[count.index]

    tags = {
        Name = "subnet_privada_${count.index}"
    }
}


// Criando as Tabelas de Rotas (Route Tables)

// Criando a route table publica

resource "aws_route_table" "tabela_publica" {
    vpc_id = aws_vpc.tutorial_vpc.id
  
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.net_gateway.id
    }
}

resource "aws_route_table_association" "public" {

    count           = var.subnet_count.public

    route_table_id  = aws_route_table.tabela_publica.id  
    subnet_id       = aws_subnet.publics_subsnets[count.index].id
  
}

// Criando a route table privada

resource "aws_route_table" "tabela_privada" {
    vpc_id = aws_vpc.tutorial_vpc.id
}

resource "aws_route_table_association" "private" {

    count               = var.subnet_count.private

    route_table_id      = aws_route_table.tabela_privada.id

    subnet_id           = aws_subnet.privadas_subnets[count.index].id  
}

// Crianção dos Security Groups 

resource "aws_security_group" "tutorial_web_sg" {

    name        = "tutortial_web_sg"
    description = "Security group para web servers"
    vpc_id      = aws_vpc.tutorial_vpc.id 

    ingress {
        description = " permitir o trafico http"
        from_port   = "80"
        to_port     = "80"
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"] 
    } 

    ingress {
        description = " permitindo ssh com computador"
        from_port   = "22"
        to_port     = "22"
        protocol    = "tcp"
        // aqui vamos usar o nosso ip 
        cidr_blocks = ["${var.my_ip}/32"] 
    }

    egress {
        description = "Permitindo a saida"
        from_port   = 0 
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]  
    }

    tags = {
      Name = "tutotial_web_sg"
    } 
}

// Criando os Security Group para o rds

resource "aws_security_group" "tutorial_db_sg" {

    name        = "tutorial_db_sg"
    description = "Security Group para a database"

    vpc_id      = aws_vpc.tutorial_vpc.id 

    ingress {
        description     = "Permitir a conexao MySQL apenas com a instancia ec2"
        from_port       = "3306"
        to_port         = "3306"
        protocol        = "tcp"
        security_groups = [aws_security_group.tutorial_web_sg.id]  
    } 

    tags = {
        Name = "tutorial_db_sg"
    }
  
}

// Criando um grupo de subnet para database
resource "aws_db_subnet_group" "tutorial_db_subnet_group" {

    name        = "tutorial_db_subnet_group"
    description = "DB subnet group"

    subnet_ids = [for subnets in aws_subnet.privadas_subnets : subnets.id]
  
}
// Criando o MySQL RDS Database 

resource "aws_db_instance" "tutorial_database" {
    
    allocated_storage   = var.settings.database.allocated_storage 

    engine              = var.settings.database.engine

    engine_version      = var.settings.database.engine_version

    instance_class      = var.settings.database.instance_class

    db_name             = var.settings.database.db_name

    username            = var.db_username

    password            = var.db_password

    db_subnet_group_name = aws_db_subnet_group.tutorial_db_subnet_group.id 

    vpc_security_group_ids = [aws_security_group.tutorial_db_sg.id]       
    
    skip_final_snapshot = 	var.settings.database.skip_final_snapshot
}


// se não tiver criar um par de chaves com o comando
/*
ssh-keygen -t rsa -b 4096 -m pem -f tutorial_kp && openssl rsa -in tutorial_kp -outform pem && chmod 400 tutorial_kp.pem

*/


resource "aws_key_pair" "tutorial_kp"{
    key_name = "vamo_teste"

    public_key = file("vamo_teste.pem.pub")
}
// Criando as instancias ec2 
// Primeira buscando a ami da instancia
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
// Com a ami feita, agora podemos criar a instancia de fato

resource "aws_instance" "tutorial_web" {

    count               = var.settings.web_app.count

    ami                 = data.aws_ami.ubuntu.id 

    instance_type       = var.settings.web_app.instance_type 
  
    subnet_id = aws_subnet.publics_subsnets[count.index].id

    key_name = aws_key_pair.tutorial_kp.key_name

    vpc_security_group_ids = [aws_security_group.tutorial_web_sg.id]

    tags = {
        Name = "tutorial_web_${count.index}"
    }

}

// Criando elastic IP para as instancias ec2 

resource "aws_eip" "tutorial_web_eip" {

    count = var.settings.web_app.count

    instance = aws_instance.tutorial_web[count.index].id

    tags = {
      Name = "tutorial_web_eip_${count.index}"
    }

}