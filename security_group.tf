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