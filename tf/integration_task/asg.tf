resource "aws_launch_configuration" "edu" {
  name_prefix     = var.name_prefix
  image_id        = var.asg_image_id
  instance_type   = var.asg_instance_type
  security_groups = [aws_security_group.asg.id]
  
  associate_public_ip_address = true
  
  enable_monitoring = true

  user_data       = <<EOF
#!/bin/bash
mkdir /var/www
yum update -y
yum -y install amazon-efs-utils
sudo mount -t efs -o tls ${aws_efs_file_system.efs.id} /var/www
chmod go+rw /var/www
yum update -y
sudo yum install -y httpd
sudo amazon-linux-extras install -y php7.2
yum install wget -y
wget http://repo.mysql.com/mysql-community-release-el6-5.noarch.rpm
rpm -ivh mysql-community-release-el6-5.noarch.rpm
yum install mysql-server -y
yum install  php-mysqlnd -y
cd /var/www/html
chmod go+rw /var/www/html
echo "healthy" > healthy.html
wget https://wordpress.org/latest.tar.gz
tar -xzf latest.tar.gz
cp -r wordpress/* /var/www/html/
rm -rf wordpress
rm -rf latest.tar.gz
chmod -R 755 wp-content
chown -R apache:apache wp-content
chkconfig httpd on
cp wp-config-sample.php wp-config.php
sed -i "s@define( 'DB_NAME', 'database_name_here' );@define('DB_NAME', '${module.db.db_instance_name}');@g" wp-config.php
sed -i "s@define( 'DB_USER', 'username_here' );@define('DB_USER', '${module.db.db_instance_username}');@g" wp-config.php
sed -i "s@define( 'DB_PASSWORD', 'password_here' );@define('DB_PASSWORD', '${module.db.db_instance_password}');@g" wp-config.php
sed -i "s@define( 'DB_HOST', 'localhost' );@define('DB_HOST', '${module.db.db_instance_endpoint}');@g" wp-config.php
sed -i "s@define( 'WP_DEBUG', false );@define( 'WP_DEBUG', true );\n\rdefine( 'WP_DEBUG_LOG', true );@g" wp-config.php
# echo "define( 'WP_DEBUG_LOG', true );" >> wp-config.php
systemctl start httpd

rpm -i https://artifacts.elastic.co/downloads/beats/filebeat/filebeat-7.5.1-x86_64.rpm
cd /home/ec2-user/
sudo echo "filebeat.inputs:" > filebeat.yml
sudo echo "- type: log" >> filebeat.yml
sudo echo "  enabled: true" >> filebeat.yml
sudo echo "  paths:" >> filebeat.yml
sudo echo "    - /var/log/*.log" >> filebeat.yml
sudo echo "    - /var/log/httpd/access_log" >> filebeat.yml
sudo echo "    - /var/log/httpd/error_log" >> filebeat.yml
sudo echo "    - /var/www/html/wp_content/debug.log" >> filebeat.yml
sudo echo "filebeat.config.modules:" >> filebeat.yml
sudo echo "  path: \$\{path.config}/modules.d/*.yml" >> filebeat.yml
sudo echo "  reload.enabled: false" >> filebeat.yml
sudo echo "setup.template.settings:" >> filebeat.yml
sudo echo "  index.number_of_shards: 1" >> filebeat.yml
sudo echo "setup.kibana:" >> filebeat.yml
sudo echo "  host: "${aws_instance.kibana.private_ip}:5601"" >> filebeat.yml
sudo echo "output.logstash:" >> filebeat.yml
sudo echo "  hosts: ["${aws_instance.logstash[0].private_ip}:5044", "${aws_instance.logstash[1].private_ip}:5044"]" >> filebeat.yml
sudo echo "processors:" >> filebeat.yml
sudo echo "  - add_host_metadata: ~" >> filebeat.yml
sudo echo "  - add_cloud_metadata: ~" >> filebeat.yml
sudo echo "  - add_docker_metadata: ~" >> filebeat.yml
sudo echo "  - add_kubernetes_metadata: ~" >> filebeat.yml

sudo rm /etc/filebeat/filebeat.yml
sudo cp filebeat.yml /etc/filebeat/

sudo systemctl start filebeat.service
EOF

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "terramino" {
  depends_on = [
    aws_efs_file_system.efs,
    module.db.db,
    aws_instance.logstash,
    aws_instance.kibana
  ]

  min_size             = var.asg_min_size
  max_size             = var.asg_max_size
  desired_capacity     = var.asg_desired_capacity
  launch_configuration = aws_launch_configuration.edu.name
  vpc_zone_identifier  = [aws_subnet.hawordpress-private-eu-central-1a.id, aws_subnet.hawordpress-private-eu-central-1b.id]
  target_group_arns    = "${module.alb.target_group_arns}"
}
