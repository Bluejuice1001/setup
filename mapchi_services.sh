#!/bin/bash

function show_intro() {
    clear
    echo "*********************************************"
    echo "                 MAPCHI Services               "
    echo "*********************************************"
}

function update_server() {
    echo "Updating server packages..."
    sudo apt update
    sudo apt upgrade -y
    sudo apt dist-upgrade -y
    sudo apt autoremove -y
    echo "Server packages updated successfully."
}

function setup_ssl_and_nginx() {
    echo "Setting up SSL certificates and Nginx..."
    
    # Get SSL certificate
    sudo certbot -d mapchi.com
    sudo certbot -d api.mapchi.com
    sudo certbot -d staging.mapchi.com
    sudo certbot -d www.mapchi.com

    # Setup Nginx
    sudo mv /root/setup/www.mapchi.com /etc/nginx/sites-available/
    sudo mv /root/setup/mapchi.com /etc/nginx/sites-available/
    sudo mv /root/setup/api.mapchi.com /etc/nginx/sites-available/
    sudo mv /root/setup/staging.mapchi.com /etc/nginx/sites-available/
    cd /etc/nginx/sites-enabled
    rm mapchisetup.com
    rm api.mapchisetup.com
    rm www.mapchi.com
    ln -s ../sites-available/www.mapchi.com .
    rm mapchi.com
    ln -s ../sites-available/mapchi.com .
    rm api.mapchi.com
    ln -s ../sites-available/api.mapchi.com .
    rm staging.mapchi.com
    ln -s ../sites-available/staging.mapchi.com .

    # Restart some services
    service nginx restart
    supervisorctl restart mapchecrm_django
    service nginx restart

    echo "SSL certificates and Nginx setup completed successfully."
}

function brand_new_server() {
    while true; do
        show_intro
        echo "Setup New Server Instance"
        echo "1. Create New Server Instance"
        echo "2. Setup SSL Certificates and Nginx"
        echo "x. Back to Menu"
        echo -n "Enter your choice (1, 2, or x): "
        read brand_new_choice

        case $brand_new_choice in
            1) setup_new_server;;
            2) setup_ssl_and_nginx;;
            x) break;;
            *) echo "Invalid choice. Please try again.";;
        esac
    done
}

function setup_new_server() {
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
    rm -rf /root/setup/pgloader_config.load

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
cd /webapps/mapchi/environment_3_8_2/
rm -fr mapchecrm-main
sudo -u mapchiuser git clone 'https://github.com/Bluejuice1001/mapchecrm-main.git'
cd mapchecrm-main
rm -fr /webapps/mapchi/environment_3_8_2/mapchecrm_django
mv mapchecrm_django/ /webapps/mapchi/environment_3_8_2/
cd /webapps/mapchi/environment_3_8_2/
rm -fr mapchecrm-main


# Move file req.txt to be accessible by mapchiuser
sudo mv /root/setup/req.txt /webapps/mapchi/req.txt
sudo chown mapchiuser:webapps /webapps/mapchi/req.txt

# Install dependencies
pip install -r /webapps/mapchi/req.txt

echo "Copy settings file to new location"
sudo mv /root/setup/settingsprod.py /webapps/mapchi/environment_3_8_2/mapchecrm_django/mapchecrm_django/

echo "Change defaults settings.pg to settingsprod/py"
deactivate
source /webapps/mapchi/environment_3_8_2/bin/activate
cd /webapps/mapchi/environment_3_8_2/mapchecrm_django
sudo mkdir /webapps/mapchi/environment_3_8_2/mapchecrm_django/static
python manage.py collectstatic --settings=mapchecrm_django.settingsprod

sudo chown -R mapchiuser:webapps /webapps/mapchi/environment_3_8_2/

# Add new tables to postgres
source /webapps/mapchi/environment_3_8_2/bin/activate
cd /webapps/mapchi/environment_3_8_2/mapchecrm_django
python manage.py makemigrations --settings mapchecrm_django.settingsprod
python manage.py migrate --settings mapchecrm_django.settingsprod
supervisorctl restart mapchecrm_django

# Add compiled website front
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
rm -fr /root/setup/pgloader_config.load

# Only if i have to dumb and move data accross
#python manage.py dumpdata > data.json
#python manage.py loaddata data.json --settings=mapchecrm_django.settingsprod

# Output completion message
#echo "DB migration successfull"

    echo "Mapchi Django and Vue updated successfully."
}

function restore_database() {
    while true; do
        show_intro
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
    backup_dir="/webapps/mapchi/DB-Backup/"

    # Check if the backup directory exists
    if [ -d "$backup_dir" ]; then
        # Find the latest backup file
        latest_backup=$(ls -t "$backup_dir" | head -n1)

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
    else
        echo "Backup directory $backup_dir not found."
    fi

    echo "Latest backup restored successfully."
}

function restore_specific_version() {
    echo "Restoring with a specific version..."
    
    # Assuming backup files are stored in /webapps/mapchi/DB-Backup
    backup_directory="/webapps/mapchi/DB-Backup"
    
    # List available backup files
    echo "Available backup versions:"
    ls -1 $backup_directory

    # Prompt user for the specific version
    echo -n "Enter the backup version to restore (e.g., backup_file_20231127_153316.dump): "
    read specific_version

    # Check if the specified version exists
    if [ -f "$backup_directory/$specific_version" ]; then
        # Add your steps to restore with a specific version here
        PGPASSWORD=mapchipassword pg_restore -h localhost -U mapchiuser -d mapchi -Fc -c "$backup_directory/$specific_version"
        echo "Specific version '$specific_version' restored successfully."
    else
        echo "Error: Backup version '$specific_version' not found. Exiting..."
        exit 1
    fi
}

function database_menu() {
    while true; do
        show_intro
        echo "Database Menu"
        echo "1. Create Mapchi Database"
        echo "2. Drop Mapchi Database"
        #echo "3. Copy Data to Database (Caution this will overwrite client data, we will backup the database before data is copied)"
        echo "3. Update Database Structure"
        echo "x. Back to Menu"
        echo -n "Enter your choice (1, 2, 3, 4, or x): "
        read db_choice

        case $db_choice in
            1) create_database;;
            2) drop_database;;
            #3) copy_data_to_database;;
            3) create_database_structure;;
            x) break;;
            *) echo "Invalid choice. Please try again.";;
        esac
    done
}

function create_database() {
    echo "Creating database..."

    # Create PostgreSQL Database
    sudo -u postgres psql -c "CREATE DATABASE mapchi;"
    sudo -u postgres psql -c "CREATE USER mapchiuser WITH PASSWORD 'mapchipassword';"
    sudo -u postgres psql -c "ALTER ROLE mapchiuser SET client_encoding TO 'utf8';"
    sudo -u postgres psql -c "ALTER ROLE mapchiuser SET default_transaction_isolation TO 'read committed';"
    sudo -u postgres psql -c "ALTER ROLE mapchiuser SET timezone TO 'UTC';"
    sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE mapchi TO mapchiuser;"
    sudo -u postgres psql -c "ALTER USER mapchiuser WITH SUPERUSER;"
    
    echo "Database created successfully."
}

function drop_database() {
    echo "Dropping database..."
    # Add your steps to drop a database here
    dropdb -h localhost -U mapchiuser mapchi
    echo "Database dropped successfully."
}

function copy_data_to_database() {
    echo "Copying data to database..."
    
    # Only if i have to dumb and move data accross
    cd /webapps/mapchi/environment_3_8_2/mapchecrm_django
    python manage.py dumpdata > data.json
    #python manage.py loaddata data.json --settings=mapchecrm_django.settingsprod
    
    echo "Data copied to database successfully."
}

function create_database_structure() {
    echo "Update database structure..."

    # Add new tables to postgres
    source /webapps/mapchi/environment_3_8_2/bin/activate
    cd /webapps/mapchi/environment_3_8_2/mapchecrm_django
    python manage.py makemigrations --settings mapchecrm_django.settingsprod
    python manage.py migrate --settings mapchecrm_django.settingsprod
    supervisorctl restart mapchecrm_django

    echo "Database structure updated successfully."
}

function backupDB() {
 echo "Backing up client data..."
 
 current_date=$(date +"%Y%m%d_%H%M%S")
 backup_file="/webapps/mapchi/DB-Backup/manual-backup_file_${current_date}.dump"
 PGPASSWORD=mapchipassword pg_dump -h localhost -U mapchiuser -d mapchi -Fc -f "${backup_file}"

 echo "Backup completed successfully."
}

function edit_settings() {
    echo "Editing settingsprod.py..."
    
    # Full path to settingsprod.py file
    settings_file="/webapps/mapchi/environment_3_8_2/mapchecrm_django/mapchecrm_django/settingsprod.py"

    # Check if the settings file exists
    if [ -f "$settings_file" ]; then
        # Open the settingsprod.py file for editing
        nano "$settings_file"
        
        echo "settingsprod.py edited successfully."
    else
        echo "Error: settingsprod.py file not found at $settings_file"
    fi
}

# Display menu
while true; do
    show_intro
    echo "Mapchi Services Menu"
    echo "1. New Server"
    echo "2. Upload new Mapchi version"
    echo "3. Update Server Software Packages"
    
    if [ -d "/webapps/mapchi/DB-Backup" ]; then
        echo "4. Database"
        echo "5. Restore Client Data"
        echo "6. Edit settingsprod.py"
        echo "x. Exit"
        echo -n "Enter your choice (1, 2, 3, 4, 5, 6, or x): "
    else
        echo "x. Exit"
        echo -n "Enter your choice (1, 2, 3, or x): "
    fi
    
    read choice

    case $choice in
        1) brand_new_server;;
        2) update_code;;
        3) update_server;;
        4) database_menu;;
        5) restore_database;;
        6) edit_settings;;
        x) exit;;
        *) echo "Invalid choice. Please try again.";;
    esac
done

