resource "aws_launch_template" "web_template" {
    image_id = data.aws_ami.ubuntu.id
    instance_type = "t2.micro"
    
    key_name = "proj_link"  
    
    network_interfaces {
      security_groups = [aws_security_group.securityGroupLoad.id]
    }

    

    user_data = base64encode(<<-EOF
            #!/bin/bash
            sudo apt-get update
            sudo apt-get install pip -y
            pip install flask
            cd /home/ubuntu
            git clone https://github.com/LinkolnR/api_p_cloud_testes
            cd api_p_cloud_testes/
            echo 'DB_HOST=${aws_db_instance.database.endpoint}' > .env
            echo 'DB_PORT=${aws_db_instance.database.port}' >> .env
            echo 'DB_NAME=${aws_db_instance.database.identifier}' >> .env
            echo 'DB_USER=${var.db_username}' >> .env
            echo 'DB_PASSWORD=${var.db_password}' >> .env
            python3 app.py
            EOF
            )

      


    tag_specifications {
      resource_type = "instance"
      tags = {
        Name = "aquele_template"
      }
    }
}

