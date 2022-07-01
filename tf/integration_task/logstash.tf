resource "aws_instance" "logstash" {
  depends_on = [
    null_resource.install_kibana
  ]
  count                       = var.logstash_count
  ami                         = var.logstash_ami
  instance_type               = var.logstash_instance_type
  subnet_id                   = aws_subnet.hawordpress-private-eu-central-1b.id
  vpc_security_group_ids      = [aws_security_group.logstash_sg.id]
  key_name                    = aws_key_pair.elastic_ssh_key.key_name
  associate_public_ip_address = true
  tags = {
    Name = "logstash"
  }
}

data "template_file" "init_logstash" {
  depends_on = [
    aws_instance.logstash
  ]
  template = file("./logstash_config.tpl")
  vars = {
    elasticsearch1 = aws_instance.es_master_nodes[0].private_ip
    elasticsearch2 = aws_instance.es_master_nodes[1].private_ip
  }
}

resource "null_resource" "move_logstash_file" {
  depends_on = [
    aws_instance.logstash
  ]
  count = var.logstash_count
  connection {
    type                = "ssh"
    user                = "ec2-user"
    private_key         = file("tf-kp")
    host                = aws_instance.logstash[count.index].private_ip
    bastion_host        = aws_instance.bastion.public_ip
    bastion_user        = "ubuntu"
    bastion_private_key = file("tf-kp")
  }
  provisioner "file" {
    content     = data.template_file.init_logstash.rendered
    destination = "logstash.conf"
  }
}


resource "null_resource" "install_logstash" {
  depends_on = [
    aws_instance.logstash
  ]
  count = var.logstash_count
  connection {
    type                = "ssh"
    user                = "ec2-user"
    private_key         = file("tf-kp")
    host                = aws_instance.logstash[count.index].private_ip
    bastion_host        = aws_instance.bastion.public_ip
    bastion_user        = "ubuntu"
    bastion_private_key = file("tf-kp")
  }
  provisioner "remote-exec" {
    inline = [
      "sudo yum update -y && sudo yum install java-1.8.0-openjdk -y",
      "sudo rpm -i https://artifacts.elastic.co/downloads/logstash/logstash-7.5.1.rpm",
      "sudo cp logstash.conf /etc/logstash/conf.d/logstash.conf",
      "sudo systemctl start logstash.service"
    ]
  }
}
