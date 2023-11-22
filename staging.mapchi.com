server {
    listen 80;
    server_name staging.mapchi.com;
    return 301 https://staging.mapchi.com$request_uri;
}

server {
    listen 443 ssl;
    server_name staging.mapchi.com;

    client_max_body_size 4G;

    error_log  /webapps/mapchi/environment_3_8_2/logs/nginx-vue-error.log;
    access_log /webapps/mapchi/environment_3_8_2/logs/nginx-vue-access.log;

    ssl_certificate /etc/letsencrypt/live/staging.mapchi.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/staging.mapchi.com/privkey.pem;

    ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
    ssl_prefer_server_ciphers on;
    ssl_ciphers 'EECDH+AESGCM:EDH+AESGCM:AES256+EECDH:AES256+EDH';

    charset utf-8;
    root /webapps/mapchi/staging_dist;
    index index.html index.htm;

    location / {
        auth_basic "Staging Area";                        # Add this line
        auth_basic_user_file /webapps/mapchi/.htpasswd;          # Add this line

        root /webapps/mapchi/staging_dist;
        try_files $uri /index.html;

    }
}
