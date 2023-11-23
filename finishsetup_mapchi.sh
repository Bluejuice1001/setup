#!/bin/bash

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

# Output completion message
echo "Mapchi setup completed successfully."

# Reboot server
#sudo reboot now
