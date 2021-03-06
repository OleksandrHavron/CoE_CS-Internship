# Sample Logstash configuration for creating a simple
# Beats -> Logstash -> Elasticsearch pipeline.

input {
  beats {
    port => 5044
  }
}

output {
  elasticsearch {
    hosts => ["http://${elasticsearch1}:9200", "http://${elasticsearch2}:9200"]
    index => "logstash"
  }
}