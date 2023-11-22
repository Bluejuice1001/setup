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
sudo -H pip3 install --upgrade pip
sudo -H pip3 install virtualenv

# Create group and user for the Mapchi project
sudo mkdir -p /webapps/mapchi
sudo groupadd --system webapps
sudo useradd --system --gid webapps --shell /bin/bash --home /webapps/mapchi mapchiuser

# Create Mapchi environment
cd /webapps/mapchi
sudo -u mapchiuser virtualenv environment_3_8_2
source environment_3_8_2/bin/activate
cd environment_3_8_2/
sudo -u mapchiuser git clone 'https://github.com/Bluejuice1001/mapchecrm-main.git'
cd mapchecrm-main
mv mapchecrm_django/..
rm -fr mapchecrm-main

# Install dependencies
sudo -u mapchiuser pip install -r setup/req.txt
sudo -u mapchiuser pip install psycopg2-binary

# Output completion message
echo "Mapchi setup completed successfully."
