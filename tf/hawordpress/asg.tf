resource "aws_launch_configuration" "edu" {
  name_prefix     = "education-"
  image_id        = "ami-05f5f4f906feab6a7"
  instance_type   = "t2.micro"
  security_groups = [aws_security_group.asg.id]
  
  enable_monitoring = true

  user_data       = <<EOF
  #!/bin/bash
  mkdir /var/www
  yum update -y
  yum -y install amazon-efs-utils
  mount -t efs -o tls ${aws_efs_file_system.efs.id} /var/www
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
  service httpd start
  # cp wp-config-sample.php wp-config.php
  # sed -i "s/define( 'DB_NAME', 'database_name_here' );/define('DB_NAME', '${module.db.db_instance_name}');/g" wp-config.php
  # sed -i "s/define( 'DB_USER', 'username_here' );/define('DB_USER', '${module.db.db_instance_username}');/g" wp-config.php
  # sed -i "s/define( 'DB_PASSWORD', 'password_here' );/define('DB_PASSWORD', '${module.db.db_instance_password}');/g" wp-config.php
  # sed -i "s/define( 'DB_HOST', 'localhost' );/define('DB_HOST', '${module.db.db_instance_endpoint}');/g" wp-config.php
  EOF

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "terramino" {
  depends_on = [
    aws_efs_file_system.efs,
    module.db.db
  ]

  min_size             = 0
  max_size             = 2
  desired_capacity     = 2
  launch_configuration = aws_launch_configuration.edu.name
  vpc_zone_identifier  = module.vpc.private_subnets
  target_group_arns    = "${module.alb.target_group_arns}"
}
