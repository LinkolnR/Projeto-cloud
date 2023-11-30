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

# variables para autoscaling
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


variable "db_username" {
  description = "Database master user"
  type        = string
  sensitive   = true
}

// This variable contains the database master password
// We will be storing this in a secrets file
variable "db_password" {
  description = "Database master user password"
  type        = string
  sensitive   = true
}