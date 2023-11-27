#!/bin/bash

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
    pg_restore -h localhost -U mapchiuser -d mapchi -Fc -c "$backup_file"

    echo "Restore completed."
else
    echo "No backup files found in $backup_dir"
fi
