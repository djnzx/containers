server {
    listen          443 ssl;
    server_name     am.kiev.ua www.am.kiev.ua;

    ssl_certificate     /etc/nginx/certs/server.crt;
    ssl_certificate_key /etc/nginx/certs/server.key;

    location / {
        proxy_pass  http://host.docker.internal:8080;
    }
}

