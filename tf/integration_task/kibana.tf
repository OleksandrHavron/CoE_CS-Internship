resource "aws_instance" "kibana" {
  depends_on = [
    null_resource.start_es
  ]
  ami                         = var.kibana_ami
  instance_type               = var.kibana_instance_type
  subnet_id                   = aws_subnet.hawordpress-public-eu-central-1a.id
  vpc_security_group_ids      = [aws_security_group.kibana_sg.id]
  key_name                    = aws_key_pair.elastic_ssh_key.key_name
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
    elasticsearch = aws_instance.es_master_nodes[1].private_ip
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

data "template_file" "oauth2-proxy-service" {
  depends_on = [
    aws_instance.kibana
  ]
  template = file("./oauth2-proxy.service")
}

resource "null_resource" "move_kibana_file" {
  depends_on = [
    aws_instance.kibana,
    aws_instance.bastion
  ]
  connection {
    type                = "ssh"
    user                = "ec2-user"
    host                = aws_instance.kibana.private_ip
    private_key         = file("tf-kp")
    bastion_host        = aws_instance.bastion.public_ip
    bastion_user        = "ubuntu"
    bastion_private_key = file("tf-kp")

  }
  provisioner "file" {
    content     = data.template_file.init_kibana.rendered
    destination = "kibana.yml"
  }
  provisioner "file" {
    content     = data.template_file.nginx_conf.rendered
    destination = "default.conf"
  }
  provisioner "file" {
    content     = data.template_file.oauth2-proxy-cfg.rendered
    destination = "oauth2-proxy.cfg"
  }
  provisioner "file" {
    content     = data.template_file.oauth2-proxy-service.rendered
    destination = "oauth2-proxy.service"
  }
}

resource "null_resource" "install_kibana" {
  depends_on = [
    aws_instance.kibana,
    aws_instance.bastion
  ]
  connection {
    type                = "ssh"
    user                = "ec2-user"
    private_key         = file("tf-kp")
    host                = aws_instance.kibana.private_ip
    bastion_host        = aws_instance.bastion.public_ip
    bastion_user        = "ubuntu"
    bastion_private_key = file("tf-kp")

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
      "sudo mkdir /opt/oauth2-proxy",
      "sudo cp oauth2-proxy-v7.3.0.linux-amd64/oauth2-proxy /opt/oauth2-proxy",
      "sudo mkdir /etc/oauth2-proxy",
      "sudo cp oauth2-proxy.cfg /etc/oauth2-proxy/",
      "sudo cp oauth2-proxy.service /etc/systemd/system/",
      "sudo systemctl start oauth2-proxy.service"
    ]
  }
}
