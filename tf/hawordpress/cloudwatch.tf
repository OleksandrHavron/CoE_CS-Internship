resource "aws_cloudwatch_dashboard" "ec2" {
  dashboard_name = "my-dashboard"

  dashboard_body = <<EOF
    {
    "widgets": [
        {
            "height": 15,
            "width": 24,
            "y": 0,
            "x": 0,
            "type": "explorer",
            "properties": {
                "metrics": [
                    {
                        "metricName": "CPUUtilization",
                        "resourceType": "AWS::EC2::Instance",
                        "stat": "Average"
                    },
                    {
                        "metricName": "DiskReadBytes",
                        "resourceType": "AWS::EC2::Instance",
                        "stat": "Average"
                    },
                    {
                        "metricName": "DiskReadOps",
                        "resourceType": "AWS::EC2::Instance",
                        "stat": "Average"
                    },
                    {
                        "metricName": "DiskWriteBytes",
                        "resourceType": "AWS::EC2::Instance",
                        "stat": "Average"
                    },
                    {
                        "metricName": "DiskWriteOps",
                        "resourceType": "AWS::EC2::Instance",
                        "stat": "Average"
                    },
                    {
                        "metricName": "NetworkIn",
                        "resourceType": "AWS::EC2::Instance",
                        "stat": "Average"
                    },
                    {
                        "metricName": "NetworkOut",
                        "resourceType": "AWS::EC2::Instance",
                        "stat": "Average"
                    },
                    {
                        "metricName": "NetworkPacketsIn",
                        "resourceType": "AWS::EC2::Instance",
                        "stat": "Average"
                    },
                    {
                        "metricName": "NetworkPacketsOut",
                        "resourceType": "AWS::EC2::Instance",
                        "stat": "Average"
                    },
                    {
                        "metricName": "StatusCheckFailed",
                        "resourceType": "AWS::EC2::Instance",
                        "stat": "Sum"
                    },
                    {
                        "metricName": "StatusCheckFailed_Instance",
                        "resourceType": "AWS::EC2::Instance",
                        "stat": "Sum"
                    },
                    {
                        "metricName": "StatusCheckFailed_System",
                        "resourceType": "AWS::EC2::Instance",
                        "stat": "Sum"
                    }
                ],
                "labels": [
                    {
                        "key": "aws:autoscaling:groupName",
                        "value": "terraform-2022052607183565850000000b"
                    }
                ],
                "widgetOptions": {
                    "legend": {
                        "position": "bottom"
                    },
                    "view": "timeSeries",
                    "stacked": false,
                    "rowsPerPage": 50,
                    "widgetsPerRow": 2
                },
                "period": 300,
                "splitBy": "",
                "region": "eu-central-1"
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
  threshold           = "80"
  evaluation_periods  = "2"
  period              = "120"
  statistic           = "Average"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.terramino.name
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
  statistic           = "Average"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.terramino.name
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
  statistic           = "Average"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.terramino.name
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
    AutoScalingGroupName = aws_autoscaling_group.terramino.name
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
    AutoScalingGroupName = aws_autoscaling_group.terramino.name
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
    DBInstanceIdentifier = module.db.db_instance_name
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
    DBInstanceIdentifier = module.db.db_instance_name
  }
}

resource "aws_cloudwatch_metric_alarm" "rds_free_ls" {
  alarm_description   = "Monitors CPU utilization for Terramino ASG"
  alarm_name          = "rds_free_ls"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  namespace           = "AWS/RDS"
  metric_name         = "FreeLocalStorage"
  threshold           = "80"
  evaluation_periods  = "2"
  period              = "120"
  statistic           = "Average"

  dimensions = {
    DBInstanceIdentifier = module.db.db_instance_name
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
    DBInstanceIdentifier = module.db.db_instance_name
  }
}

resource "aws_cloudwatch_metric_alarm" "asg_gp_in_srvc_cpct" {
  alarm_description   = "Monitors CPU utilization for Terramino ASG"
  alarm_name          = "asg_gp_in_srvc_cpct"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  namespace           = "AWS/AutoScaling"
  metric_name         = "GroupInServiceCapacity"
  threshold           = "5"
  evaluation_periods  = "2"
  period              = "120"
  statistic           = "Maximum"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.terramino.name
  }
}

resource "aws_cloudwatch_metric_alarm" "efs_strg_bts" {
  alarm_description   = "Monitors CPU utilization for Terramino ASG"
  alarm_name          = "efs_strg_bts"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  namespace           = "AWS/EFS"
  metric_name         = "StorageBytes"
  threshold           = "80"
  evaluation_periods  = "2"
  period              = "120"
  statistic           = "Average"

  dimensions = {
    FileSystemId = aws_efs_file_system.efs.id
  }
}

resource "aws_cloudwatch_metric_alarm" "alb_actv_conn_count" {
  alarm_description   = "Monitors CPU utilization for Terramino ASG"
  alarm_name          = "alb_actv_conn_count"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  namespace           = "AWS/ApplicationELB"
  metric_name         = "ActiveConnectionCount"
  threshold           = "80"
  evaluation_periods  = "2"
  period              = "120"
  statistic           = "Sum"

  dimensions = {
    LoadBalancer = module.alb.lb_dns_name
  }
}

resource "aws_cloudwatch_metric_alarm" "foobar" {
  alarm_name                = "elastic_health"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "2"
  metric_name               = "ES_Health"
  namespace                 = "ES_CLUSTER"
  period                    = "120"
  statistic                 = "SampleCount"
  threshold                 = "1"
  alarm_description         = "This metric monitors elasticsearch cluster health"
  insufficient_data_actions = []
}
