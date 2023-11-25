// Definindo a região da aws

variable "aws_region"  {
    default = "us-east-1"
}

// variável para configuração da VPC
// o CIDR da vpc
variable "vpc_cidr_block" {
    description = "CIDR para a VPC"
    type = string
    default = "10.0.0.0/16"
}

// Variavel para as subnets 
// número de subnets privadas e públicas
variable "subnet_count" {
    description = "Número de Subnets"
    type = map(number)
    default = {
      public = 1,
      private = 2
    }
}

// variaveis para configurações das instancias
// EC2 e RDS
variable "settings" {
    description = "Configurações das instancias"
    type =  map(any)
    default = {
      "database" = {
        allocated_storage   = 10
        engine              = "mysql"
        engine_version      = "5.7"
        instance_class      = "db.t2.micro"
        db_name             = "banco_dados"
        skip_final_snapshot = true
      }
      "web_app" = {
        count               = 1 // número de instancias ec2
        instance_type       = "t2.micro" // tipo da instancia
      }
    }
}

// criando os blocos das subnets públicas
// começando criando 4 por enquanto 
variable "public_subnet_cidr_blocks" {
    description = "Blocos de CIDR disponíveis para a rede pública"
    type        = list(string)
    default = [ 
        "10.0.1.0/24",
        "10.0.2.0/24",
        "10.0.3.0/24",
        "10.0.4.0/24"
     ]
}

// criando os blocos das subnets privadas
// começando criando 4 por enquanto 
variable "private_subnet_cidr_blocks" {
    description = "Blocos de CIDR disponíveis para a rede privada"
    type        = list(string)
    default = [ 
        "10.0.101.0/24",
        "10.0.102.0/24",
        "10.0.103.0/24",
        "10.0.104.0/24"
     ]
}

// meu ip, para configurar o ssh
variable "my_ip" {
    description = "Meu IP"
    type        = string
    sensitive = true
}
// username do database
variable "db_username" {
    description = "Username da base de dados"
    type        = string 
    sensitive   = true
}

// senha do banco de dados 
variable "db_password" {
    description = "senha do banco de dados"
    type        = string 
    sensitive   = true
}