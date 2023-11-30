resource "aws_launch_template" "web_template" {
    image_id = "ami-0fc5d935ebf8bc3bc"
    instance_type = "t2.micro"
    
    key_name = "proj_link"  
    
    network_interfaces {
      security_groups = [aws_security_group.securityGroupLoad.id]

    }

    

    user_data = base64encode(templatefile("user_data.tftpl",{db_host=aws_db_instance.database.endpoint,db_name=aws_db_instance.database.identifier,db_port=aws_db_instance.database.port,db_user=var.db_username , db_password=var.db_password }))


      


    tag_specifications {
      resource_type = "instance"
      tags = {
        Name = "aquele_template"
      }
    }
}

