
server.host: "0.0.0.0"

server.name: "kibana"

elasticsearch.hosts: ["http://${elasticsearch}:9200"]

# xpack.security.authc.providers: [saml]

xpack.security.cookieName: "sid"
xpack.security.encryptionKey: "e_xhBeWnj_svud8q91Jz50vc_E9xOK_v4hyTcjG4A10="

elasticsearch.requestHeadersWhitelist: [ "Authorization", "sgtenant", "x-forwarded-for", "x-proxy-user", "x-proxy-roles" ]

elasticsearch.username: "elastic"
elasticsearch.password: "kibanaserver"

# xpack.security.authc.providers: [token]
