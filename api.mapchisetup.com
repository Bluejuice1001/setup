upstream mapchecrm_app_server {
    server unix:/webapps/mapchi/environment_3_8_2/run/gunicorn.sock fail_timeout=0;
}

server {
    listen 8500;
    server_name 188.166.85.225;
#    return 301 http://146.190.224.201$request_uri;

    client_max_body_size 4G;

    access_log /webapps/mapchi/environment_3_8_2/logs/nginx-django-access.log;
    error_log /webapps/mapchi/environment_3_8_2/logs/nginx-django-error.log;

    location /static/ {
        alias /webapps/mapchi/environment_3_8_2/mapchecrm_django/static/;
    }

    location /media/ {
        alias /webapps/mapchi/environment_3_8_2/mapchecrm_django/media/;
    }

    location / {
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header Host $http_host;
        proxy_redirect off;

        if (!-f $request_filename) {
            proxy_pass http://mapchecrm_app_server;
        }
    }
}
