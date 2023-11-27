#!/bin/bash

# Add new tables to postgres
cd /webapps/mapchi/environment_3_8_2/mapchecrm_django
python manage.py makemigrations --settings mapchecrm_django.settingsprod
python manage.py migrate --settings mapchecrm_django.settingsprod
supervisorctl restart mapchecrm_django

# Output completion message
echo "DB migration successfull"

