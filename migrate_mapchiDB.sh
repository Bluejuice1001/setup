#!/bin/bash

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

# Only if i have to dumb and move data accross
#python manage.py dumpdata > data.json
#python manage.py loaddata data.json --settings=mapchecrm_django.settingsprod

# Output completion message
echo "DB migration successfull"

