server {
    listen 80;
    server_name mapchi.com;
    return 301 https://www.mapchi.com$request_uri;
}

server {
    listen 443 ssl;
    server_name mapchi.com;

    client_max_body_size 4G;

    error_log  /webapps/mapchi/environment_3_8_2/logs/nginx-vue-error.log;
    access_log /webapps/mapchi/environment_3_8_2/logs/nginx-vue-access.log;

    ssl_certificate /etc/letsencrypt/live/mapchi.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/mapchi.com/privkey.pem;

    ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
    ssl_prefer_server_ciphers on;
    ssl_ciphers 'EECDH+AESGCM:EDH+AESGCM:AES256+EECDH:AES256+EDH';

    charset utf-8;
    root /webapps/mapchi/dist;
    index index.html index.htm;

    location / {
        root /webapps/mapchi/dist;
        try_files $uri /index.html;
    }

   location /loader.js {
        add_header 'Access-Control-Allow-Origin' '*';
        try_files $uri /index.html;
    }

   location /loaderiframe.js {
        add_header 'Access-Control-Allow-Origin' '*';
        try_files $uri /index.html;
    }

   location /loaderwidget.js {
        add_header 'Access-Control-Allow-Origin' '*';
        try_files $uri /index.html;
    }

   location /loaderiframetest.js {
        add_header 'Access-Control-Allow-Origin' '*';
        try_files $uri /index.html;
    }

}
