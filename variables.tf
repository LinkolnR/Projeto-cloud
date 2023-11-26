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
variable "subnets" {
    description = "Definindo as subnets para as instancias"
    type        = list(string)
    default = [ 
        "10.0.0.0/24",
        "10.0.1.0/24"
     ]
}