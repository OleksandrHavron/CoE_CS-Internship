#!/bin/bash


usermod -a G apache ec2-user
chown -R ec2-user:apache /var/www
chmod 2775 /var/www
find /var/www -type d -exec chmod 2775 {} \;
find /var/www -type f -exec chmod 0664 {} \;
# mkdir /var/www/html
# cd /tmp
# wget https://www.wordpress.org/latest.tar.gz
# cd /var/www/html
