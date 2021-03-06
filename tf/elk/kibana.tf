resource "aws_instance" "kibana" {
  depends_on = [ 
    null_resource.start_es
   ]
  ami                    = "ami-05f5f4f906feab6a7"
  instance_type          = "t2.small"
  subnet_id = aws_subnet.hawordpress-public-eu-central-1a.id
  vpc_security_group_ids = [aws_security_group.kibana_sg.id]
  key_name               = aws_key_pair.elastic_ssh_key.key_name
  associate_public_ip_address = true
  tags = {
    Name = "kibana"
  }
}

data "template_file" "init_kibana" {
  depends_on = [ 
    aws_instance.kibana
  ]
  template = file("./kibana_config.tpl")
  vars = {
    elasticsearch = aws_instance.es_master_nodes[1].public_ip
  }
}

data "template_file" "nginx_conf" {
  depends_on = [ 
    aws_instance.kibana
  ]
  template = file("./nginx.conf")
  vars = {
    kibana = aws_instance.kibana.public_ip
  }
}

data "template_file" "oauth2-proxy-cfg" {
  depends_on = [ 
    aws_instance.kibana
  ]
  template = file("./oauth2-proxy.cfg")
  vars = {
    kibana = aws_instance.kibana.public_ip
  }
}

resource "null_resource" "move_kibana_file" {
  depends_on = [ 
    aws_instance.kibana
   ]
  connection {
     type = "ssh"
     user = "ec2-user"
     private_key = file("tf-kp")
     host= aws_instance.kibana.public_ip
  } 
  provisioner "file" {
    content = data.template_file.init_kibana.rendered
    destination = "kibana.yml"
  }
  provisioner "file" {
    content = data.template_file.nginx_conf.rendered
    destination = "default.conf"
  }
  provisioner "file" {
    content = data.template_file.oauth2-proxy-cfg.rendered
    destination = "oauth2-proxy.cfg"
  }
}

resource "null_resource" "install_kibana" {
  depends_on = [ 
      aws_instance.kibana
   ]
  connection {
    type = "ssh"
    user = "ec2-user"
    private_key = file("tf-kp")
    host= aws_instance.kibana.public_ip
  } 
  provisioner "remote-exec" {
    inline = [
      "sudo yum update -y",
      "sudo rpm -i https://artifacts.elastic.co/downloads/kibana/kibana-7.5.1-x86_64.rpm",
      "sudo rm /etc/kibana/kibana.yml",
      "sudo cp kibana.yml /etc/kibana/",
      "sudo systemctl start kibana",
      "sudo amazon-linux-extras install nginx1 -y", 
      "sudo cp default.conf /etc/nginx/conf.d/",
      "sudo systemctl enable nginx",
      "sudo systemctl start nginx",
      "cd /home/ec2-user",
      "wget https://github.com/oauth2-proxy/oauth2-proxy/releases/download/v7.3.0/oauth2-proxy-v7.3.0.linux-amd64.tar.gz",
      "tar -xzvf oauth2-proxy-v7.3.0.linux-amd64.tar.gz",
      "sudo cp oauth2-proxy-v7.3.0.linux-amd64/oauth2-proxy /bin/",
      #"oauth2-proxy --config oauth2-proxy.cfg --provider=github &"
    ]
  }
}