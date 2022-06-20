#!/bin/bash
sudo mkdir /var/www
sudo yum update -y
sudo yum -y install amazon-efs-utils
sudo mount -t efs -o tls ${aws_efs_file_system.efs.id} /var/www
sudo chmod go+rw /var/www
sudo yum update -y
sudo yum install -y httpd
sudo amazon-linux-extras install -y php7.2
sudo yum install wget -y
sudo wget http://repo.mysql.com/mysql-community-release-el6-5.noarch.rpm
sudo rpm -ivh mysql-community-release-el6-5.noarch.rpm
sudo yum install mysql-server -y
sudo yum install  php-mysqlnd -y
cd /var/www/html
sudo chmod go+rw /var/www/html
sudo echo "healthy" > healthy.html
sudo wget https://wordpress.org/latest.tar.gz
sudo tar -xzf latest.tar.gz
sudo cp -r wordpress/* /var/www/html/
sudo rm -rf wordpress
sudo rm -rf latest.tar.gz
sudo chmod -R 755 wp-content
sudo chown -R apache:apache wp-content
sudo chkconfig httpd on
sudo cp wp-config-sample.php wp-config.php
sudo sed -i "s@define( 'DB_NAME', 'database_name_here' );@define('DB_NAME', '${module.db.db_instance_name}');@g" wp-config.php
sudo sed -i "s@define( 'DB_USER', 'username_here' );@define('DB_USER', '${module.db.db_instance_username}');@g" wp-config.php
sudo sed -i "s@define( 'DB_PASSWORD', 'password_here' );@define('DB_PASSWORD', '${module.db.db_instance_password}');@g" wp-config.php
sudo sed -i "s@define( 'DB_HOST', 'localhost' );@define('DB_HOST', '${module.db.db_instance_endpoint}');@g" wp-config.php
sudo sed -i "s@define( 'WP_DEBUG', false );@define( 'WP_DEBUG', true );@g" wp-config.php
sudo echo "define( 'WP_DEBUG_LOG', true );" >> wp-config.php
sudo systemctl start httpd

sudo rpm -i https://artifacts.elastic.co/downloads/beats/filebeat/filebeat-7.5.1-x86_64.rpm
cd /home/ec2-user/
sudo cat <<EOF > filebeat.yml
filebeat.inputs:
- type: log
  enabled: true
  paths:
    - /var/log/*.log
    - /var/www/html/wp_content/debug.log

filebeat.config.modules:
  path: \${path.config}/modules.d/*.yml
  reload.enabled: false

setup.template.settings:
  index.number_of_shards: 1
setup.kibana:
  host: "${aws_instance.kibana.public_ip}:5601"
output.logstash:
  hosts: ["${aws_instance.logstash[0].public_ip}:5044", "${aws_instance.logstash[1].public_ip}:5044"]
processors:
  - add_host_metadata: ~
  - add_cloud_metadata: ~
  - add_docker_metadata: ~
  - add_kubernetes_metadata: ~

EOF

# sudo rm /etc/filebeat/filebeat.yml
# sudo cp filebeat.yml /etc/filebeat/

sudo systemctl start filebeat.service