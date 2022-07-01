resource "aws_key_pair" "elastic_ssh_key" {
  key_name   = "tf-kp"
  public_key = file("tf-kp.pub")
}

variable "es_data_nodes_number" {
  type    = number
  default = 4

}

variable "es_master_nodes_number" {
  type    = number
  default = 2

}

resource "aws_instance" "es_master_nodes" {
  count                       = var.es_master_nodes_number
  ami                         = "ami-05f5f4f906feab6a7"
  instance_type               = "t2.large"
  subnet_id                   = count.index < var.es_master_nodes_number / 2 ? aws_subnet.hawordpress-private-eu-central-1a.id : aws_subnet.hawordpress-private-eu-central-1b.id
  vpc_security_group_ids      = [aws_security_group.elasticsearch_sg.id]
  associate_public_ip_address = true

  key_name = aws_key_pair.elastic_ssh_key.key_name
  tags = {
    Name = "es_master_node_${count.index}"
  }
}

data "template_file" "init_master_elasticsearch" {
  depends_on = [
    aws_instance.es_master_nodes,
    aws_instance.es_data_nodes
  ]
  count    = var.es_master_nodes_number
  template = file("./elasticsearch_master_config.tpl")
  vars = {
    cluster_name = "cluster1"
    node_name    = "master_node_${count.index}"
    node         = aws_instance.es_master_nodes[count.index].private_ip
    node1        = aws_instance.es_data_nodes[0].private_ip
    node2        = aws_instance.es_data_nodes[1].private_ip
    node3        = aws_instance.es_data_nodes[2].private_ip
    node4        = aws_instance.es_data_nodes[3].private_ip
    node5        = aws_instance.es_master_nodes[0].private_ip
    node6        = aws_instance.es_master_nodes[1].private_ip
  }
}

resource "null_resource" "move_master_elasticsearch_file" {
  count = var.es_master_nodes_number
  connection {
    type                = "ssh"
    user                = "ec2-user"
    private_key         = file("tf-kp")
    host                = aws_instance.es_master_nodes[count.index].private_ip
    bastion_host        = aws_instance.bastion.public_ip
    bastion_user        = "ubuntu"
    bastion_private_key = file("tf-kp")
  }
  provisioner "file" {
    content     = data.template_file.init_master_elasticsearch[count.index].rendered
    destination = "elasticsearch.yml"
  }
}

resource "null_resource" "start_master_es" {
  depends_on = [
    null_resource.move_master_elasticsearch_file
  ]
  count = var.es_master_nodes_number
  connection {
    type                = "ssh"
    user                = "ec2-user"
    private_key         = file("tf-kp")
    host                = aws_instance.es_master_nodes[count.index].private_ip
    bastion_host        = aws_instance.bastion.public_ip
    bastion_user        = "ubuntu"
    bastion_private_key = file("tf-kp")
  }

  provisioner "remote-exec" {
    inline = [
      "#!/bin/bash",
      "sudo yum update -y",
      "sudo rpm -i https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-7.5.1-x86_64.rpm",
      "sudo systemctl daemon-reload",
      "sudo systemctl enable elasticsearch.service",
      "sudo sed -i 's@-Xms1g@-Xms${aws_instance.es_master_nodes[count.index].root_block_device[0].volume_size / 2}g@g' /etc/elasticsearch/jvm.options",
      "sudo sed -i 's@-Xmx1g@-Xmx${aws_instance.es_master_nodes[count.index].root_block_device[0].volume_size / 2}g@g' /etc/elasticsearch/jvm.options",
      "sudo rm /etc/elasticsearch/elasticsearch.yml",
      "sudo cp elasticsearch.yml /etc/elasticsearch/",
      "sudo systemctl start elasticsearch.service"
    ]
  }
}

resource "aws_instance" "es_data_nodes" {
  count                       = var.es_data_nodes_number
  ami                         = "ami-05f5f4f906feab6a7"
  instance_type               = "t2.large"
  subnet_id                   = count.index < var.es_master_nodes_number / 2 ? aws_subnet.hawordpress-private-eu-central-1a.id : aws_subnet.hawordpress-private-eu-central-1b.id
  vpc_security_group_ids      = [aws_security_group.elasticsearch_sg.id]
  associate_public_ip_address = true

  key_name = aws_key_pair.elastic_ssh_key.key_name
  tags = {
    Name = "es_data_node_${count.index}"
  }
}

data "template_file" "init_elasticsearch" {
  depends_on = [
    aws_instance.es_data_nodes,
    aws_instance.es_master_nodes
  ]
  count    = var.es_data_nodes_number
  template = file("./elasticsearch_data_config.tpl")
  vars = {
    cluster_name = "cluster1"
    node_name    = "node_${count.index}"
    node         = aws_instance.es_data_nodes[count.index].private_ip
    node1        = aws_instance.es_data_nodes[0].private_ip
    node2        = aws_instance.es_data_nodes[1].private_ip
    node3        = aws_instance.es_data_nodes[2].private_ip
    node4        = aws_instance.es_data_nodes[3].private_ip
    node5        = aws_instance.es_master_nodes[0].private_ip
    node6        = aws_instance.es_master_nodes[1].private_ip
  }
}

resource "null_resource" "move_elasticsearch_file" {
  count = var.es_data_nodes_number
  connection {
    type                = "ssh"
    user                = "ec2-user"
    private_key         = file("tf-kp")
    host                = aws_instance.es_data_nodes[count.index].private_ip
    bastion_host        = aws_instance.bastion.public_ip
    bastion_user        = "ubuntu"
    bastion_private_key = file("tf-kp")
  }
  provisioner "file" {
    content     = data.template_file.init_elasticsearch[count.index].rendered
    destination = "elasticsearch.yml"
  }
}

resource "null_resource" "start_es" {
  depends_on = [
    null_resource.move_elasticsearch_file
  ]
  count = var.es_data_nodes_number
  connection {
    type                = "ssh"
    user                = "ec2-user"
    private_key         = file("tf-kp")
    host                = aws_instance.es_data_nodes[count.index].private_ip
    bastion_host        = aws_instance.bastion.public_ip
    bastion_user        = "ubuntu"
    bastion_private_key = file("tf-kp")
  }

  provisioner "remote-exec" {
    inline = [
      "#!/bin/bash",
      "sudo yum update -y",
      "sudo rpm -i https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-7.5.1-x86_64.rpm",
      "sudo systemctl daemon-reload",
      "sudo systemctl enable elasticsearch.service",
      "sudo sed -i 's@-Xms1g@-Xms${aws_instance.es_data_nodes[count.index].root_block_device[0].volume_size / 2}g@g' /etc/elasticsearch/jvm.options",
      "sudo sed -i 's@-Xmx1g@-Xmx${aws_instance.es_data_nodes[count.index].root_block_device[0].volume_size / 2}g@g' /etc/elasticsearch/jvm.options",
      "sudo rm /etc/elasticsearch/elasticsearch.yml",
      "sudo cp elasticsearch.yml /etc/elasticsearch/",
      "sudo systemctl start elasticsearch.service"
    ]
  }
}
