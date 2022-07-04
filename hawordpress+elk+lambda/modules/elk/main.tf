################################################################################
# SSH key
################################################################################

resource "aws_key_pair" "elastic_ssh_key" {
  key_name   = var.ssh_key_name
  public_key = file(var.ssh_key_path)
}

################################################################################
# Bastion
################################################################################

resource "aws_instance" "bastion" {
  ami                         = var.bastion_ami
  instance_type               = var.bastion_instance_type
  subnet_id                   = var.bastion_subnet_id
  vpc_security_group_ids      = var.bastion_vpc_security_group_ids
  associate_public_ip_address = var.bastion_associate_public_ip_addressi
  key_name                    = aws_key_pair.elastic_ssh_key.key_name

  tags = {
    Name = "bastion"
  }
}

################################################################################
# Elastic Search
################################################################################

resource "aws_instance" "es_master_node" {
  count         = var.es_master_node_count
  ami           = var.es_master_node_ami
  instance_type = var.es_master_node_instance_type
  subnet_id     = var.es_subnet_ids[count.index % length(var.es_subnet_ids)]
  # subnet_id                   = count.index < var.es_master_node_count / length(var.es_master_node_subnet_ids) ? aws_subnet.hawordpress-private-eu-central-1a.id : aws_subnet.hawordpress-private-eu-central-1b.idvar.es_master_node_subnet_id
  vpc_security_group_ids      = var.es_master_node_vpc_security_group_ids
  associate_public_ip_address = var.es_master_node_associate_public_ip_address
  key_name                    = aws_key_pair.elastic_ssh_key.key_name

  tags = {
    Name = "es_master_node_${count.index}"
  }
}

resource "aws_instance" "es_data_node" {
  count         = var.es_data_node_count
  ami           = var.es_data_node_ami
  instance_type = var.es_data_node_instance_type
  subnet_id     = var.es_subnet_ids[count.index % length(var.es_subnet_ids)]
  #subnet_id                   = var.es_data_node_subnet_id
  vpc_security_group_ids      = var.es_data_node_vpc_security_group_ids
  associate_public_ip_address = var.es_data_node_associate_public_ip_address
  key_name                    = aws_key_pair.elastic_ssh_key.key_name
  tags = {
    Name = "es_data_node_${count.index}"
  }
}

data "template_file" "init_master_elasticsearch" {
  depends_on = [
    aws_instance.es_master_node,
    aws_instance.es_data_node
  ]
  count    = var.es_master_node_count
  template = file(var.es_master_node_template_file_path)
  vars = {
    cluster_name = var.es_cluster_name
    node_name    = "master_node_${count.index}"
    node         = aws_instance.es_master_node[count.index].private_ip
    node1        = aws_instance.es_data_node[0].private_ip
    node2        = aws_instance.es_data_node[1].private_ip
    node3        = aws_instance.es_data_node[2].private_ip
    node4        = aws_instance.es_data_node[3].private_ip
    node5        = aws_instance.es_master_node[0].private_ip
    node6        = aws_instance.es_master_node[1].private_ip
  }
}

resource "null_resource" "move_master_elasticsearch_file" {
  count = var.es_master_node_count
  connection {
    type                = "ssh"
    user                = var.es_connection_user
    private_key         = file(var.es_connection_private_key_path)
    host                = aws_instance.es_master_node[count.index].private_ip
    bastion_host        = aws_instance.bastion.public_ip
    bastion_user        = var.connection_bastion_user
    bastion_private_key = file(var.connection_bastion_private_key_path)
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
  count = var.es_master_node_count
  connection {
    type                = "ssh"
    user                = var.es_connection_user
    private_key         = file(var.es_connection_private_key_path)
    host                = aws_instance.es_master_node[count.index].private_ip
    bastion_host        = aws_instance.bastion.public_ip
    bastion_user        = var.connection_bastion_user
    bastion_private_key = file(var.connection_bastion_private_key_path)
  }

  provisioner "remote-exec" {
    inline = [
      "#!/bin/bash",
      "sudo yum update -y",
      "sudo rpm -i https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-7.5.1-x86_64.rpm",
      "sudo systemctl daemon-reload",
      "sudo systemctl enable elasticsearch.service",
      "sudo sed -i 's@-Xms1g@-Xms${aws_instance.es_master_node[count.index].root_block_device[0].volume_size / 2}g@g' /etc/elasticsearch/jvm.options",
      "sudo sed -i 's@-Xmx1g@-Xmx${aws_instance.es_master_node[count.index].root_block_device[0].volume_size / 2}g@g' /etc/elasticsearch/jvm.options",
      "sudo rm /etc/elasticsearch/elasticsearch.yml",
      "sudo cp elasticsearch.yml /etc/elasticsearch/",
      "sudo systemctl start elasticsearch.service"
    ]
  }
}


data "template_file" "init_data_elasticsearch" {
  depends_on = [
    aws_instance.es_data_node,
    aws_instance.es_master_node
  ]
  count    = var.es_data_node_count
  template = file(var.es_data_node_template_file_path)
  vars = {
    cluster_name = "cluster1"
    node_name    = "node_${count.index}"
    node         = aws_instance.es_data_node[count.index].private_ip
    node1        = aws_instance.es_data_node[0].private_ip
    node2        = aws_instance.es_data_node[1].private_ip
    node3        = aws_instance.es_data_node[2].private_ip
    node4        = aws_instance.es_data_node[3].private_ip
    node5        = aws_instance.es_master_node[0].private_ip
    node6        = aws_instance.es_master_node[1].private_ip
  }
}

resource "null_resource" "move_data_elasticsearch_file" {
  count = var.es_data_node_count
  connection {
    type                = "ssh"
    user                = var.es_connection_user
    private_key         = file(var.es_connection_private_key_path)
    host                = aws_instance.es_data_node[count.index].private_ip
    bastion_host        = aws_instance.bastion.public_ip
    bastion_user        = var.connection_bastion_user
    bastion_private_key = file(var.connection_bastion_private_key_path)
  }
  provisioner "file" {
    content     = data.template_file.init_data_elasticsearch[count.index].rendered
    destination = "elasticsearch.yml"
  }
}

resource "null_resource" "start_data_es" {
  depends_on = [
    null_resource.move_data_elasticsearch_file
  ]
  count = var.es_data_node_count
  connection {
    type                = "ssh"
    user                = var.es_connection_user
    private_key         = file(var.es_connection_private_key_path)
    host                = aws_instance.es_data_node[count.index].private_ip
    bastion_host        = aws_instance.bastion.public_ip
    bastion_user        = var.connection_bastion_user
    bastion_private_key = file(var.connection_bastion_private_key_path)
  }

  provisioner "remote-exec" {
    inline = [
      "#!/bin/bash",
      "sudo yum update -y",
      "sudo rpm -i https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-7.5.1-x86_64.rpm",
      "sudo systemctl daemon-reload",
      "sudo systemctl enable elasticsearch.service",
      "sudo sed -i 's@-Xms1g@-Xms${aws_instance.es_data_node[count.index].root_block_device[0].volume_size / 2}g@g' /etc/elasticsearch/jvm.options",
      "sudo sed -i 's@-Xmx1g@-Xmx${aws_instance.es_data_node[count.index].root_block_device[0].volume_size / 2}g@g' /etc/elasticsearch/jvm.options",
      "sudo rm /etc/elasticsearch/elasticsearch.yml",
      "sudo cp elasticsearch.yml /etc/elasticsearch/",
      "sudo systemctl start elasticsearch.service"
    ]
  }
}

################################################################################
# Kibana
################################################################################

resource "aws_instance" "kibana" {
  depends_on = [
    null_resource.start_data_es
  ]
  ami                         = var.kibana_ami
  instance_type               = var.kibana_instance_type
  subnet_id                   = var.kibana_subnet_id
  vpc_security_group_ids      = var.kibana_vpc_security_group_ids
  key_name                    = aws_key_pair.elastic_ssh_key.key_name
  associate_public_ip_address = var.kibana_associate_public_ip_address
  tags = {
    Name = "kibana"
  }
}

data "template_file" "init_kibana" {
  depends_on = [
    aws_instance.kibana
  ]
  template = file(var.kibana_template_file_path)
  vars = {
    elasticsearch = aws_instance.es_master_node[1].private_ip
  }
}

data "template_file" "nginx_conf" {
  depends_on = [
    aws_instance.kibana
  ]
  template = file(var.nginx_template_file_path)
  vars = {
    kibana = aws_instance.kibana.public_ip
  }
}

data "template_file" "oauth2-proxy-cfg" {
  depends_on = [
    aws_instance.kibana
  ]
  template = file(var.oauth2_template_file_path)
  vars = {
    kibana = aws_instance.kibana.public_ip
  }
}

data "template_file" "oauth2-proxy-service" {
  depends_on = [
    aws_instance.kibana
  ]
  template = file(var.oauth2_service_template_file_path)
}

resource "null_resource" "move_kibana_file" {
  depends_on = [
    aws_instance.kibana,
    aws_instance.bastion
  ]
  connection {
    type                = "ssh"
    user                = var.kibana_connection_user
    host                = aws_instance.kibana.private_ip
    private_key         = file(var.kibana_connection_private_key_path)
    bastion_host        = aws_instance.bastion.public_ip
    bastion_user        = var.connection_bastion_user
    bastion_private_key = file(var.connection_bastion_private_key_path)

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
    private_key         = file(var.kibana_connection_private_key_path)
    host                = aws_instance.kibana.private_ip
    bastion_host        = aws_instance.bastion.public_ip
    bastion_user        = var.connection_bastion_user
    bastion_private_key = file(var.connection_bastion_private_key_path)

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


################################################################################
# Logstash
################################################################################

resource "aws_instance" "logstash" {
  depends_on = [
    null_resource.install_kibana
  ]
  count                       = var.logstash_count
  ami                         = var.logstash_ami
  instance_type               = var.logstash_instance_type
  subnet_id                   = var.logstash_subnet_id
  vpc_security_group_ids      = var.logstash_vpc_security_group_ids
  key_name                    = aws_key_pair.elastic_ssh_key.key_name
  associate_public_ip_address = var.logstash_associate_public_ip_address
  tags = {
    Name = "logstash"
  }
}

data "template_file" "init_logstash" {
  depends_on = [
    aws_instance.logstash
  ]
  template = file(var.logstash_template_file_path)
  vars = {
    elasticsearch1 = aws_instance.es_master_node[0].private_ip
    elasticsearch2 = aws_instance.es_master_node[1].private_ip
  }
}

resource "null_resource" "move_logstash_file" {
  depends_on = [
    aws_instance.logstash
  ]
  count = var.logstash_count
  connection {
    type                = "ssh"
    user                = var.logstash_connection_user
    private_key         = file(var.logstash_connection_private_key_path)
    host                = aws_instance.logstash[count.index].private_ip
    bastion_host        = aws_instance.bastion.public_ip
    bastion_user        = var.connection_bastion_user
    bastion_private_key = file(var.connection_bastion_private_key_path)
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
    user                = var.logstash_connection_user
    private_key         = file(var.logstash_connection_private_key_path)
    host                = aws_instance.logstash[count.index].private_ip
    bastion_host        = aws_instance.bastion.public_ip
    bastion_user        = var.connection_bastion_user
    bastion_private_key = file(var.connection_bastion_private_key_path)
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


################################################################################
# Filebeat
################################################################################

resource "null_resource" "move_filebeat_file" {
  count = var.filebeat_count

  connection {
    type                = "ssh"
    user                = var.filebeat_connection_user
    private_key         = file(var.filebeat_connection_private_key_path)
    host                = var.filebeat_connection_hosts[count.index]
    bastion_host        = aws_instance.bastion.public_ip
    bastion_user        = var.connection_bastion_user
    bastion_private_key = file(var.connection_bastion_private_key_path)
  }
  provisioner "file" {
    source = "./modules/elk/etc/filebeat.yml"
    destination  = "filebeat.yml"
  }
}


resource "null_resource" "install_filebeat" {
  depends_on = [
    null_resource.move_filebeat_file
  ]
  count = var.filebeat_count

  connection {
    type                = "ssh"
    user                = var.filebeat_connection_user
    private_key         = file(var.filebeat_connection_private_key_path)
    host                = var.filebeat_connection_hosts[count.index]
    bastion_host        = aws_instance.bastion.public_ip
    bastion_user        = var.connection_bastion_user
    bastion_private_key = file(var.connection_bastion_private_key_path)
  }
  provisioner "remote-exec" {
    inline = [
      "sudo yum update -y",
      "sudo rpm -i https://artifacts.elastic.co/downloads/beats/filebeat/filebeat-7.5.1-x86_64.rpm",
      "sudo sed -i 's@kibana_ip@${aws_instance.kibana.public_ip}@g' filebeat.yml",
      "sudo sed -i 's@logstash1_ip@${aws_instance.logstash[0].public_ip}@g' filebeat.yml",
      "sudo sed -i 's@logstash2_ip@${aws_instance.logstash[1].public_ip}@g' filebeat.yml",
      "sudo rm /etc/filebeat/filebeat.yml",
      "sudo rm /etc/filebeat/filebeat.yml",
      "sudo cp filebeat.yml /etc/filebeat/",
      "sudo systemctl start filebeat.service"

    ]
  }
}

################################################################################
# CloudWatch
################################################################################


resource "aws_cloudwatch_metric_alarm" "elastic_health" {
  alarm_name                = "elastic_health"
  comparison_operator       = "LessThanThreshold"
  evaluation_periods        = "2"
  metric_name               = "cluster_health"
  namespace                 = "ES_CLUSTER"
  period                    = "120"
  statistic                 = "Maximum"
  threshold                 = "1"
  alarm_description         = "This metric monitors elasticsearch cluster health"
  insufficient_data_actions = []

  dimensions = {
    "Cluster name" = "cluster1"
  }

}

################################################################################
# Route53
################################################################################

# resource "aws_route53_record" "elk" {
#   zone_id = data.aws_route53_zone.hawordpress.zone_id
#   name    = var.aws_route53_zone_kibana
#   type    = "A"

#   records = ["${aws_instance.kibana.public_ip}"]
#   ttl     = 300
# }


# resource "aws_route53_zone" "elasticsearch" {
#   name = "elasticsearch.ohavron-ocg1.link"

#   vpc {
#     vpc_id = aws_vpc.hawordpress.id
#   }
# }


# resource "aws_route53_record" "elasticsearch" {
#   zone_id = aws_route53_zone.elasticsearch.zone_id
#   name    = aws_route53_zone.elasticsearch.name
#   type    = "A"

#   records = ["${aws_instance.es_master_nodes[1].private_ip}"]
#   ttl     = 300
# }

# resource "aws_route53_zone" "logstash" {
#   name = "logstash.ohavron-ocg1.link"

#   vpc {
#     vpc_id = aws_vpc.hawordpress.id
#   }
# }


