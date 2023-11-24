#!/bin/bash

# Update and upgrade
sudo apt update
sudo apt upgrade -y
sudo apt dist-upgrade -y
sudo apt autoremove -y

# Install required software
sudo apt-get install -y python3-pip python3-dev libpq-dev postgresql postgresql-contrib nginx

# Install Certbot and set up Nginx
sudo apt install -y certbot python3-certbot-nginx

# Create PostgreSQL Database
sudo -u postgres psql -c "CREATE DATABASE mapchi;"
sudo -u postgres psql -c "CREATE USER mapchiuser WITH PASSWORD 'mapchipassword';"
sudo -u postgres psql -c "ALTER ROLE mapchiuser SET client_encoding TO 'utf8';"
sudo -u postgres psql -c "ALTER ROLE mapchiuser SET default_transaction_isolation TO 'read committed';"
sudo -u postgres psql -c "ALTER ROLE mapchiuser SET timezone TO 'UTC';"
sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE mapchi TO mapchiuser;"

# Enable and start Nginx
#sudo systemctl enable nginx
#sudo systemctl start nginx

# Install virtualenv for Mapchi
sudo -H pip install --upgrade pip
sudo -H pip install virtualenv

# Create group and user for the Mapchi project
sudo mkdir -p /webapps/mapchi
sudo groupadd --system webapps
sudo useradd --system --gid webapps --shell /bin/bash --home /webapps/mapchi mapchiuser
sudo chown -R mapchiuser:webapps /webapps/mapchi/
# Create Mapchi environment
cd /webapps/mapchi
sudo -u mapchiuser virtualenv environment_3_8_2
source environment_3_8_2/bin/activate
cd environment_3_8_2/
rm -fr mapchecrm-main
sudo -u mapchiuser git clone 'https://github.com/Bluejuice1001/mapchecrm-main.git'
cd mapchecrm-main
rm -fr /webapps/mapchi/environment_3_8_2/mapchecrm_django
mv mapchecrm_django/ /webapps/mapchi/environment_3_8_2/
rm -fr mapchecrm-main


# Move file req.txt to be accessible by mapchiuser
sudo mv /root/setup/req.txt /webapps/mapchi/req.txt
sudo chown mapchiuser:webapps /webapps/mapchi/req.txt

# Install dependencies
#sudo -u mapchiuser pip install -r /webapps/mapchi/req.txt
#sudo -u mapchiuser pip install psycopg2-binary
pip install -r /webapps/mapchi/req.txt
pip install psycopg2-binary

# Copy settings file to new location
sudo mv /root/setup/settingsprod.py /webapps/mapchi/environment_3_8_2/mapchecrm_django/mapchecrm_django/

# Install and setup Gunicorn
pip install gunicorn
sudo mkdir /webapps/mapchi/environment_3_8_2/run
sudo mv /root/setup/gunicorn_start /webapps/mapchi/environment_3_8_2/bin/gunicorn_start
sudo chmod +x /webapps/mapchi/environment_3_8_2/bin/gunicorn_start

# Install and setup Supervisor
sudo apt install supervisor
sudo mkdir /webapps/mapchi/environment_3_8_2/logs
sudo touch /webapps/mapchi/environment_3_8_2/logs/supervisor.log
sudo chown -R mapchiuser:webapps /webapps/mapchi/environment_3_8_2/
sudo mv /root/setup/mapchecrm_django.conf /etc/supervisor/conf.d/
supervisorctl reread
supervisorctl update

# Setup Nginx
sudo mv /root/setup/mapchisetup.com /etc/nginx/sites-available/
sudo mv /root/setup/api.mapchisetup.com /etc/nginx/sites-available/
cd /etc/nginx/sites-enabled
rm mapchisetup.com
ln -s ../sites-available/mapchisetup.com .
rm api.mapchisetup.com
ln -s ../sites-available/api.mapchisetup.com .

# Restart some services
service nginx restart
supervisorctl restart mapchecrm_django
service nginx restart

# Change default settings.py to settingsprod.py, adds database columns for new changes
deactivate
source /webapps/mapchi/environment_3_8_2/bin/activate
cd /webapps/mapchi/environment_3_8_2/mapchecrm_django
sudo mkdir /webapps/mapchi/environment_3_8_2/mapchecrm_django/static
#python manage.py makemigrations --settings mapchecrm_django.settingsprod
#python manage.py migrate --settings mapchecrm_django.settingsprod
python manage.py collectstatic --settings=mapchecrm_django.settingsprod
supervisorctl restart mapchecrm_django

# Install Static files Django Admin
#deactivate
#source /webapps/mapchi/environment_3_8_2/bin/activate
#cd /webapps/mapchi/environment_3_8_2/mapchecrm_django
#python manage.py collectstatic
sudo chown -R mapchiuser:webapps /webapps/mapchi/environment_3_8_2/


# Add compiled website front (First one live website, second one staging website)
sudo mv /root/setup/dist /webapps/mapchi/dist
sudo mkdir /webapps/mapchi/dist/.well-known
sudo mv /root/setup/apple-developer-merchantid-domain-association /webapps/mapchi/dist/.well-known
sudo mv /root/setup/iframe.html /webapps/mapchi/dist/
sudo mv /root/setup/widget.html /webapps/mapchi/dist/
sudo mv /root/setup/loader.js /webapps/mapchi/dist/
sudo mv /root/setup/loaderiframe.js /webapps/mapchi/dist/
sudo mv /root/setup/loaderiframetest.js /webapps/mapchi/dist/
sudo mv /root/setup/loaderwidget.js /webapps/mapchi/dist/
sudo mv /root/setup/sitemap.xml /webapps/mapchi/dist/
sudo mv /root/setup/robots.txt /webapps/mapchi/dist/

#sudo mv /root /webapps/mapchi/staging_dist


# Remove old files
rm -fr /webapps/mapchi/environment_3_8_2/mapchecrm-main
rm -fr /webapps/mapchi/req.txt

# Output completion message
echo "Mapchi setup completed successfully."

# Reboot server
#sudo reboot now
