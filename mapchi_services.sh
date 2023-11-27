#!/bin/bash

function update_server() {
    echo "Updating server packages..."
    sudo apt update
    sudo apt upgrade -y
    sudo apt dist-upgrade -y
    sudo apt autoremove -y
    echo "Server packages updated successfully."
}

function brand_new_server() {
    echo "Setting up a brand new server instance..."
    echo "Update and upgrade server to be up to date"
    sudo apt update
    sudo apt upgrade -y
    sudo apt dist-upgrade -y
    sudo apt autoremove -y

    echo "Install required software"
    sudo apt-get install -y python3-pip python3-dev libpq-dev postgresql postgresql-contrib nginx

    echo "Install Certbot and set up Nginx"
    sudo apt install -y certbot python3-certbot-nginx

    echo "Create PostgreSQL Database"
    sudo apt install pgloader
    sudo -u postgres psql -c "CREATE DATABASE mapchi;"
    sudo -u postgres psql -c "CREATE USER mapchiuser WITH PASSWORD 'mapchipassword';"
    sudo -u postgres psql -c "ALTER ROLE mapchiuser SET client_encoding TO 'utf8';"
    sudo -u postgres psql -c "ALTER ROLE mapchiuser SET default_transaction_isolation TO 'read committed';"
    sudo -u postgres psql -c "ALTER ROLE mapchiuser SET timezone TO 'UTC';"
    sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE mapchi TO mapchiuser;"
    sudo -u postgres psql -c "ALTER USER mapchiuser WITH SUPERUSER;"

    echo "Install virtualenv for Mapchi"
    sudo -H pip install --upgrade pip
    sudo -H pip install virtualenv

    echo "Create group and user for the Mapchi project"
    sudo mkdir -p /webapps/mapchi
    sudo groupadd --system webapps
    sudo useradd --system --gid webapps --shell /bin/bash --home /webapps/mapchi mapchiuser
    sudo chown -R mapchiuser:webapps /webapps/mapchi/

    echo "Create Mapchi environment and copy code from github"
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


    echo "Move file Django dependencies list req.txt to be accessible by mapchiuser"
    sudo mv /root/setup/req.txt /webapps/mapchi/req.txt
    sudo chown mapchiuser:webapps /webapps/mapchi/req.txt

    echo "Install Django dependencies"
    pip install -r /webapps/mapchi/req.txt
    pip install psycopg2-binary

    echo "Copy settings file to new location"
    sudo mv /root/setup/settingsprod.py /webapps/mapchi/environment_3_8_2/mapchecrm_django/mapchecrm_django/

    echo "Install and setup Gunicorn"
        pip install gunicorn
    sudo mkdir /webapps/mapchi/environment_3_8_2/run
    sudo mv /root/setup/gunicorn_start /webapps/mapchi/environment_3_8_2/bin/gunicorn_start
    sudo chmod +x /webapps/mapchi/environment_3_8_2/bin/gunicorn_start

    echo "Install and setup Supervisor"
    sudo apt install supervisor
    sudo mkdir /webapps/mapchi/environment_3_8_2/logs
    sudo touch /webapps/mapchi/environment_3_8_2/logs/supervisor.log
    sudo chown -R mapchiuser:webapps /webapps/mapchi/environment_3_8_2/
    sudo mv /root/setup/mapchecrm_django.conf /etc/supervisor/conf.d/
    supervisorctl reread
    supervisorctl update

    echo "Setup Nginx"
    sudo mv /root/setup/mapchisetup.com /etc/nginx/sites-available/
    sudo mv /root/setup/api.mapchisetup.com /etc/nginx/sites-available/
    cd /etc/nginx/sites-enabled
    rm mapchisetup.com
    ln -s ../sites-available/mapchisetup.com .
    rm api.mapchisetup.com
    ln -s ../sites-available/api.mapchisetup.com .

    echo "Restart some services"
    service nginx restart

    echo "Change defaults settings.pg to settingsprod/py"
    deactivate
    source /webapps/mapchi/environment_3_8_2/bin/activate
    cd /webapps/mapchi/environment_3_8_2/mapchecrm_django
    sudo mkdir /webapps/mapchi/environment_3_8_2/mapchecrm_django/static
    python manage.py collectstatic --settings=mapchecrm_django.settingsprod


    sudo chown -R mapchiuser:webapps /webapps/mapchi/environment_3_8_2/


    echo "Add Website Front end to server from github"
    sudo mv /root/setup/dist /webapps/mapchi/dist
    sudo chown -R mapchiuser:webapps /webapps/mapchi/dist
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


    echo "Migrate data from SQLite to Postgres"
    cd /root/setup/
    pgloader pgloader_config.load

    echo "DB migration successfull"

    echo "Removing old files"
    rm -fr /webapps/mapchi/environment_3_8_2/mapchecrm-main
    rm -fr /webapps/mapchi/req.txt
    #rm -fr /root/setup/pgloader_config.load


    echo "Brand new server instance setup completed successfully."
}

function update_code() {
    echo "Deploying updated Mapchi Django and Vue version..."
    # Back-up clients database
sudo mkdir /webapps/mapchi/DB-Backup
current_date=$(date +"%Y%m%d_%H%M%S")
backup_file="/webapps/mapchi/DB-Backup/backup_file_${current_date}.dump"
PGPASSWORD=mapchipassword pg_dump -h localhost -U mapchiuser -d mapchi -Fc -f "${backup_file}"

# Copy new code
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
pip install -r /webapps/mapchi/req.txt

# Copy settings file to new location
sudo mv /root/setup/settingsprod.py /webapps/mapchi/environment_3_8_2/mapchecrm_django/mapchecrm_django/
sudo chown -R mapchiuser:webapps /webapps/mapchi/environment_3_8_2/

# Add new tables to postgres
source /webapps/mapchi/environment_3_8_2/bin/activate
cd /webapps/mapchi/environment_3_8_2/mapchecrm_django
python manage.py makemigrations --settings mapchecrm_django.settingsprod
python manage.py migrate --settings mapchecrm_django.settingsprod
supervisorctl restart mapchecrm_django

# Add compiled website front (First one live website, second one staging website)
sudo mv /root/setup/dist /webapps/mapchi/dist
sudo chown -R mapchiuser:webapps /webapps/mapchi/dist
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
rm -f /webapps/mapchi/staging_dist
sudo mv /root/dist /webapps/mapchi/staging_dist

# Remove old files
rm -fr /webapps/mapchi/environment_3_8_2/mapchecrm-main
rm -fr /webapps/mapchi/req.txt
#rm -fr /root/setup/pgloader_config.load

# Only if i have to dumb and move data accross
#python manage.py dumpdata > data.json
#python manage.py loaddata data.json --settings=mapchecrm_django.settingsprod

# Output completion message
echo "DB migration successfull"

    echo "Mapchi Django and Vue updated successfully."
}

function restore_database() {
    while true; do
        echo "Restoring database..."
        echo "1. Restore latest backup"
        echo "2. Restore with a specific version"
        echo "x. Back to Menu"
        echo -n "Enter your choice (1, 2, or x): "
        read restore_choice

        case $restore_choice in
            1) restore_latest_backup;;
            2) restore_specific_version;;
            x) break;;
            *) echo "Invalid choice. Please try again.";;
        esac
    done
}

function restore_latest_backup() {
    echo "Restoring the latest backup..."
# Directory where backups are stored
backup_dir="/webapps/mapchi/DB-Backup"

# Find the latest backup file
latest_backup=$(ls -t $backup_dir | head -n1)

# Check if a backup file exists
if [ -n "$latest_backup" ]; then
    echo "Latest backup file found: $latest_backup"

    # Full path to the latest backup file
    backup_file="$backup_dir/$latest_backup"

    # Restore the latest backup
    PGPASSWORD=mapchipassword pg_restore -h localhost -U mapchiuser -d mapchi -Fc -c "$backup_file"

    echo "Restore completed."
else
    echo "No backup files found in $backup_dir"
fi
    echo "Latest backup restored successfully."
}

function restore_specific_version() {
    echo "Restoring with a specific version..."
    # Add your steps to restore with a specific version here
    echo "Specific version restored successfully."
}

# Display menu
while true; do
    echo "Mapchi Services Menu"
    echo "1. Update Server Packages"
    echo "2. Setup Brand New Server Instance"
    echo "3. Deploy Updated Mapchi Django and Vue Version"
    echo "4. Restore Database"
    echo "x. Exit"
    echo -n "Enter your choice (1, 2, 3, 4, or x): "
    read choice

    case $choice in
        1) update_server;;
        2) brand_new_server;;
        3) update_code;;
        4) restore_database;;
        x) exit;;
        *) echo "Invalid choice. Please try again.";;
    esac
done
