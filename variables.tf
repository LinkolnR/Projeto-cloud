variable "db_username" {
  description = "Usuário da database, coloque seu username no arquivo secrets.tfvars"
  type        = string
  sensitive   = true
}

variable "db_password" {
  description = "senha da database, coloque seu username no arquivo secrets.tfvars"
  type        = string
  sensitive   = true
}

variable "key_name"{
  description = "key para utilizar para conexão com instâncias"
  type        = string 
  default = "proj_link" # Edite Aqui para o nome da sua chave gerada
} 



# Variável para a região da AWS
variable "aws_region"  {
    default = "us-east-1"
}
# Definindo o CIDR do VPC 
variable "vpc_cidr_block" {
    description = "Definindo CIDR para a VPC"
    type = string
    default = "10.0.0.0/20"
}
# Definindo as subnets
variable "subnets_publicas" {
    description = "Definindo as subnets para as instancias"
    type        = list(string)
    default = [ 
        "10.0.0.0/24",
        "10.0.1.0/24",
        "10.0.2.0/24",
        "10.0.3.0/24"
     ]
}

variable "subnets_privadas" {
    description = "Definindo as subnets para as instancias"
    type        = list(string)
    default = [ 
        "10.0.100.0/24",
        "10.0.101.0/24",
        "10.0.102.0/24",
        "10.0.103.0/24"
     ]
}

# variáveis para autoscaling
variable "min_size" {
  description = "Numero minimo de instancias no grupo"
  type        = number
  default     = 2
}

variable "max_size" {
  description = "Numero maximo de instâncias no grupo"
  type        = number
  default     = 15
}

variable "desired_capacity" {
  description = "Numero desejado de instancias no grupo"
  type        = number
  default     = 3
}

variable "instance_type" {
  description = "Tipo de instância a ser usado"
  type        = string
  default     = "t2.micro"
}

variable "cpu_alarm_threshold" {
  description = "Limite de utilização da CPU para o alarme"
  type        = number
  default     = 70
}


