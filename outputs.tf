output "web_public_ip" {
    description = "O ip de endereço do web server"
    
    value = aws_eip.tutorial_web_eip[0].public_ip 


    depends_on = [ aws_eip.tutorial_web_eip ]
  
}

output "web_public_dns" {
    description = "O DNS publico do web server"

    value = aws_eip.tutorial_web_eip[0].public_dns 
    
    depends_on = [ aws_eip.tutorial_web_eip ]
  
}

output "database_endpoint" {
    description = "A endpoint do banco de dados"
    value = aws_db_instance.tutorial_database.address  
}

output "database_port" {
    description = "A porta de conexão para o database"
    value = aws_db_instance.tutorial_database.port
  
}