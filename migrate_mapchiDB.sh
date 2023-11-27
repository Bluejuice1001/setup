#!/bin/bash

# Add new tables to postgres
sudo mkdir /webapps/mapchi/DB-Backup
current_date=$(date +"%Y%m%d_%H%M%S")
backup_file="/webapps/mapchi/DB-Backup/backup_file_${current_date}.dump"
pg_dump -h localhost -U mapchiuser -d mapchi -Fc -f "${backup_file}"
#cd /webapps/mapchi/environment_3_8_2/mapchecrm_django
#python manage.py makemigrations --settings mapchecrm_django.settingsprod
#python manage.py migrate --settings mapchecrm_django.settingsprod
#supervisorctl restart mapchecrm_django
#python manage.py dumpdata > data.json
#python manage.py loaddata data.json --settings=mapchecrm_django.settingsprod

# Output completion message
echo "DB migration successfull"

