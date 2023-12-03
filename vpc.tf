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
    cidr_block = var.subnets_publicas[count.index]

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
    cidr_block = var.subnets_publicas[3]

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

# Subnet Group para a nova VPC
resource "aws_db_subnet_group" "aws_db_subnet_group" {
  name       = "aws_db_subnet_group"
  subnet_ids = [aws_subnet.subnet-oficial[0].id,aws_subnet.subnet-oficial[1].id ,aws_subnet.subnet-rds.id] # Substitua pelos IDs das subnets da nova VPC
}

resource "aws_db_instance" "db" {
  allocated_storage    = 5
  identifier           = "terraform" 
  db_name              = "mydb"
  engine               = "mysql"
  engine_version       = "8.0.33"
  instance_class       = "db.t2.micro"
  username             = "admin"
  password             = "testeteste"
  multi_az             = true
  vpc_security_group_ids = [aws_security_group.db.id]
  db_subnet_group_name = aws_db_subnet_group.aws_db_subnet_group.id

  skip_final_snapshot  = true
}