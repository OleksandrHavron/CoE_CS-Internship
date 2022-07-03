cluster.name: ${cluster_name}

node.name: ${node_name}

node.master: true
node.data: false

path.data: /var/lib/elasticsearch

path.logs: /var/log/elasticsearch

network.host: ${node}

discovery.seed_hosts: ["${node1}", "${node2}", "${node3}", "${node4}", "${node5}", "${node6}"]

cluster.initial_master_nodes: ["master_node_0", "master_node_1"]

#xpack.security.enabled: true
#xpack.security.http.ssl.enabled: true
#xpack.security.http.ssl.keystore.path: "es-certificates.p12"
#xpack.security.http.ssl.truststore.path: "es-certificates.p12"
#xpack.security.transport.ssl.enabled: true
#xpack.security.authc.token.enabled: true
#xpack.security.authc.api_key.enabled: true