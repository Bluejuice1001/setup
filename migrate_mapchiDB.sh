#!/bin/bash

# Migrate data from sqlite to postgres
pgloader pgloader_config.load

# Output completion message
echo "DB migration successfull"

