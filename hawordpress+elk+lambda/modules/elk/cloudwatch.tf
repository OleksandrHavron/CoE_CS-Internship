
resource "aws_cloudwatch_metric_alarm" "foobar" {
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