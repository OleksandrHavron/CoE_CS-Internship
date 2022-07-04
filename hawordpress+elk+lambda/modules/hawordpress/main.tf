
locals {
  name = "hawordpress"
}

################################################################################
# Relational Database Service
################################################################################

resource "aws_db_subnet_group" "rds" {
  name       = "${local.name}-db_subnet_group"
  subnet_ids = var.rds_subnet_ids

  tags = {
    Name = local.name
  }
}

module "rds" {
  source = "terraform-aws-modules/rds/aws"

  identifier             = "${local.name}-rds"
  engine                 = var.rds_engine
  engine_version         = var.rds_engine_version
  family                 = var.rds_family
  major_engine_version   = var.rds_major_engine_version
  instance_class         = var.rds_instance_class
  storage_type           = var.rds_storage_type
  allocated_storage      = var.rds_allocated_storage
  max_allocated_storage  = var.rds_max_allocated_storage
  db_name                = var.rds_db_name
  username               = var.rds_user
  port                   = var.rds_port
  multi_az               = var.rds_multi_az
  vpc_security_group_ids = var.rds_vpc_security_group_ids
  subnet_ids             = var.rds_subnet_ids
  db_subnet_group_name   = aws_db_subnet_group.rds.name
}

################################################################################
# Elastic File System
################################################################################

resource "aws_efs_file_system" "efs" {
  creation_token   = var.efs_creation_token
  performance_mode = var.efs_perfomance_mode
  throughput_mode  = var.efs_throughput_mode
  encrypted        = var.efs_encrypted
}

data "aws_availability_zones" "available" {}

resource "aws_efs_mount_target" "efs-mt1" {
  file_system_id  = aws_efs_file_system.efs.id
  subnet_id       = var.efs-mt1_subnet_id
  security_groups = var.efs_security_group_ids
}

resource "aws_efs_mount_target" "efs-mt2" {
  file_system_id  = aws_efs_file_system.efs.id
  subnet_id       = var.efs-mt2_subnet_id
  security_groups = var.efs_security_group_ids
}

################################################################################
# Auto Scaling Group
################################################################################

resource "aws_launch_configuration" "hawordpress" {
  depends_on = [
    aws_efs_file_system.efs,
    module.rds.db,
  ]

  name_prefix                 = var.asg_name_prefix
  image_id                    = var.asg_image_id
  instance_type               = var.asg_instance_type
  security_groups             = var.asg_security_groups
  associate_public_ip_address = var.asg_associate_public_ip_address
  enable_monitoring           = var.asg_enable_monitoring

  user_data = <<EOF
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
sed -i "s@define( 'DB_NAME', 'database_name_here' );@define('DB_NAME', '${module.rds.db_instance_name}');@g" wp-config.php
sed -i "s@define( 'DB_USER', 'username_here' );@define('DB_USER', '${module.rds.db_instance_username}');@g" wp-config.php
sed -i "s@define( 'DB_PASSWORD', 'password_here' );@define('DB_PASSWORD', '${module.rds.db_instance_password}');@g" wp-config.php
sed -i "s@define( 'DB_HOST', 'localhost' );@define('DB_HOST', '${module.rds.db_instance_endpoint}');@g" wp-config.php
sed -i "s@define( 'WP_DEBUG', false );@define( 'WP_DEBUG', true );\n\rdefine( 'WP_DEBUG_LOG', true );@g" wp-config.php
systemctl start httpd
EOF

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "hawordpress" {
  depends_on = [
    aws_efs_file_system.efs,
    module.rds.db,
  ]
  name                 = var.asg_name
  min_size             = var.asg_min_size
  max_size             = var.asg_max_size
  desired_capacity     = var.asg_desired_capacity
  launch_configuration = aws_launch_configuration.hawordpress.name
  vpc_zone_identifier  = var.asg_vpc_zone_identifier
  target_group_arns    = module.alb.target_group_arns
}

################################################################################
# ACM
################################################################################

module "acm" {
  source  = "terraform-aws-modules/acm/aws"
  version = "~> 3.0"

  domain_name = var.acm_domain_name
  zone_id     = var.acm_domain_name_zone_id
}

################################################################################
# Application Load Balancer
################################################################################

module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "~> 6.0"

  name                             = "${local.name}-alb"
  load_balancer_type               = "application"
  vpc_id                           = var.alb_vpc_id
  subnets                          = var.alb_subnets
  security_groups                  = var.alb_security_groups
  enable_cross_zone_load_balancing = var.alb_enable_cross_zone_load_balancing

  target_groups = [
    {
      name_prefix      = "hawp-"
      backend_protocol = "HTTP"
      backend_port     = 80
      target_type      = "instance"

    }
  ]

  https_listeners = [
    {
      port               = 443
      protocol           = "HTTPS"
      certificate_arn    = module.acm.acm_certificate_arn
      target_group_index = 0
    }
  ]

  http_tcp_listeners = [
    {
      port        = 80
      protocol    = "HTTP"
      action_type = "redirect"
      redirect = {
        port        = "443"
        protocol    = "HTTPS"
        status_code = "HTTP_301"
      }
    }
  ]
}

################################################################################
# Route53
################################################################################

data "aws_route53_zone" "hawordpress" {
  name = var.aws_route53_zone_name
}

resource "aws_route53_record" "hawordpress" {
  zone_id = data.aws_route53_zone.hawordpress.zone_id
  name    = data.aws_route53_zone.hawordpress.name
  type    = "A"

  alias {
    name                   = module.alb.lb_dns_name
    zone_id                = module.alb.lb_zone_id
    evaluate_target_health = true
  }
}

################################################################################
# CloudWatch
################################################################################

resource "aws_cloudwatch_dashboard" "dashboard" {
  dashboard_name = "${local.name}-dashboard"

  dashboard_body = <<EOF
  {
   "widgets":[
      {
         "height":15,
         "width":24,
         "y":0,
         "x":0,
         "type":"explorer",
         "properties":{
            "metrics":[
               {
                  "metricName":"CPUUtilization",
                  "resourceType":"AWS::EC2::Instance",
                  "stat":"Average"
               },
               {
                  "metricName":"DiskReadBytes",
                  "resourceType":"AWS::EC2::Instance",
                  "stat":"Average"
               },
               {
                  "metricName":"DiskReadOps",
                  "resourceType":"AWS::EC2::Instance",
                  "stat":"Average"
               },
               {
                  "metricName":"DiskWriteBytes",
                  "resourceType":"AWS::EC2::Instance",
                  "stat":"Average"
               },
               {
                  "metricName":"DiskWriteOps",
                  "resourceType":"AWS::EC2::Instance",
                  "stat":"Average"
               },
               {
                  "metricName":"NetworkIn",
                  "resourceType":"AWS::EC2::Instance",
                  "stat":"Average"
               },
               {
                  "metricName":"NetworkOut",
                  "resourceType":"AWS::EC2::Instance",
                  "stat":"Average"
               },
               {
                  "metricName":"NetworkPacketsIn",
                  "resourceType":"AWS::EC2::Instance",
                  "stat":"Average"
               },
               {
                  "metricName":"NetworkPacketsOut",
                  "resourceType":"AWS::EC2::Instance",
                    "stat":"Average"
               },
               {
                  "metricName":"StatusCheckFailed",
                  "resourceType":"AWS::EC2::Instance",
                  "stat":"Sum"
               },
               {
                  "metricName":"StatusCheckFailed_Instance",
                  "resourceType":"AWS::EC2::Instance",
                  "stat":"Sum"
               },
               {
                  "metricName":"StatusCheckFailed_System",
                  "resourceType":"AWS::EC2::Instance",
                  "stat":"Sum"
               }
            ],
            "labels":[
               {
                  "key":"aws:autoscaling:groupName",
                  "value":"terraform-2022052607183565850000000b"
               }
            ],
            "widgetOptions":{
               "legend":{
                  "position":"bottom"
               },
               "view":"timeSeries",
               "stacked":false,
               "rowsPerPage":50,
               "widgetsPerRow":2
            },
            "period":300,
            "splitBy":"",
            "region":"eu-central-1"
         }
      }
   ]
  }
  EOF
}

resource "aws_cloudwatch_metric_alarm" "ec2_cpu_util" {
  alarm_description   = "Monitors CPU utilization for Terramino ASG"
  alarm_name          = "ec2_cpu_util"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  namespace           = "AWS/EC2"
  metric_name         = "CPUUtilization"
  threshold           = "50"
  evaluation_periods  = "2"
  period              = "120"
  statistic           = "Average"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.hawordpress.name
  }
}

resource "aws_cloudwatch_metric_alarm" "ec2_ntwrk_in" {
  alarm_description   = "Monitors CPU utilization for Terramino ASG"
  alarm_name          = "ec2_ntwrk_in"
  comparison_operator = "LessThanOrEqualToThreshold"
  namespace           = "AWS/EC2"
  metric_name         = "NetworkIn"
  threshold           = "80"
  evaluation_periods  = "2"
  period              = "120"
  statistic           = "Maximum"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.hawordpress.name
  }
}

resource "aws_cloudwatch_metric_alarm" "ec2_ntwrk_out" {
  alarm_description   = "Monitors CPU utilization for Terramino ASG"
  alarm_name          = "ec2_ntwrk_out"
  comparison_operator = "LessThanOrEqualToThreshold"
  namespace           = "AWS/EC2"
  metric_name         = "NetworkOut"
  threshold           = "80"
  evaluation_periods  = "2"
  period              = "120"
  statistic           = "Maximum"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.hawordpress.name
  }
}

resource "aws_cloudwatch_metric_alarm" "ec2_disk_read" {
  alarm_description   = "Monitors CPU utilization for Terramino ASG"
  alarm_name          = "ec2_disk_read"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  namespace           = "AWS/EC2"
  metric_name         = "DiskReadBytes"
  threshold           = "80"
  evaluation_periods  = "2"
  period              = "120"
  statistic           = "Average"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.hawordpress.name
  }
}

resource "aws_cloudwatch_metric_alarm" "ec2_disk_write" {
  alarm_description   = "Monitors CPU utilization for Terramino ASG"
  alarm_name          = "ec2_disk_write"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  namespace           = "AWS/EC2"
  metric_name         = "DiskWriteBytes"
  threshold           = "80"
  evaluation_periods  = "2"
  period              = "120"
  statistic           = "Average"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.hawordpress.name
  }
}

resource "aws_cloudwatch_metric_alarm" "rds_cpu_util" {
  alarm_description   = "Monitors CPU utilization for Terramino ASG"
  alarm_name          = "rds_cpu_util"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  namespace           = "AWS/RDS"
  metric_name         = "CPUUtilization"
  threshold           = "80"
  evaluation_periods  = "2"
  period              = "120"
  statistic           = "Average"

  dimensions = {
    DBInstanceIdentifier = module.rds.db_instance_name
  }
}

resource "aws_cloudwatch_metric_alarm" "rds_free_mem" {
  alarm_description   = "Monitors CPU utilization for Terramino ASG"
  alarm_name          = "rds_free_mem"
  comparison_operator = "LessThanOrEqualToThreshold"
  namespace           = "AWS/RDS"
  metric_name         = "FreeableMemory"
  threshold           = "80"
  evaluation_periods  = "2"
  period              = "120"
  statistic           = "Average"

  dimensions = {
    DBInstanceIdentifier = module.rds.db_instance_name
  }
}

resource "aws_cloudwatch_metric_alarm" "rds_strg_spc" {
  alarm_description   = "Monitors CPU utilization for Terramino ASG"
  alarm_name          = "rds_strg_spc"
  comparison_operator = "LessThanOrEqualToThreshold"
  namespace           = "AWS/RDS"
  metric_name         = "FreeStorageSpace"
  threshold           = "80"
  evaluation_periods  = "2"
  period              = "120"
  statistic           = "Average"

  dimensions = {
    DBInstanceIdentifier = module.rds.db_instance_name
  }
}

resource "aws_cloudwatch_metric_alarm" "efs_strg_bts" {
  alarm_description   = "Monitors CPU utilization for Terramino ASG"
  alarm_name          = "efs_strg_bts"
  comparison_operator = "LessThanOrEqualToThreshold"
  namespace           = "AWS/EFS"
  metric_name         = "StorageBytes"
  threshold           = "80"
  evaluation_periods  = "2"
  period              = "120"
  statistic           = "Average"

  dimensions = {
    FileSystemId = aws_efs_file_system.efs.id
    StorageClass = "Total"
  }
}
