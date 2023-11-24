#!/bin/bash

# Migrate data from sqlite to postgres
pgloader sqlite:///webapps/mapchi/environment_3_8_2/mapchecrm_django/db.sqlite3 "postgresql://mapchiuser:mapchipassword@localhost:5432/mapchi"

# Output completion message
echo "DB migration successfull"

