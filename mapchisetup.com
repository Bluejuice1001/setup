server {
    listen 80;
    server_name 146.190.224.201;
#    return 301 http://146.190.224.201$request_uri;

    client_max_body_size 4G;

    error_log  /webapps/mapchi/environment_3_8_2/logs/nginx-vue-error.log;
    access_log /webapps/mapchi/environment_3_8_2/logs/nginx-vue-access.log;

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
