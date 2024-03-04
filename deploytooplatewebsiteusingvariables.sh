#!/bin/bash

# Declaring Variables
URL="https://www.tooplate.com/zip-templates/2134_gotto_job.zip"
FILE_NAME="2134_gotto_job"
FILE_TYPE=".zip"
TEMP_DIR="/tmp/websitefiles"
APACHE_DOC_ROOT="/var/www/html/"

# Install wget and unzip if not already installed
echo "########################################"
echo "Installing wget and unzip..."
echo "########################################"
echo
sudo apt-get update
sudo apt-get install -y wget unzip
echo

# Install apache2 and start and enable
echo "########################################"
echo "Installing and starting apache2..."
echo "########################################"
echo
sudo apt-get install -y apache2
sudo systemctl start apache2
sudo systemctl enable apache2
echo

# Creating temp directory /tmp/websitefiles
echo "########################################"
echo "Creating temporary directory and downloading website files..."
echo "########################################"
echo
mkdir -p /tmp/websitefiles
cd /tmp/websitefiles
wget https://www.tooplate.com/zip-templates/2135_mini_finance.zip
unzip 2135_mini_finance.zip
echo

# Copying files to Apache's document root
echo "########################################"
echo "Copying files to Apache's document root..."
echo "########################################"
echo
sudo cp -r 2135_mini_finance/* /var/www/html/
echo

# Restart apache service
echo "########################################"
echo "Restarting apache2 service..."
echo "########################################"
echo
sudo systemctl restart apache2
echo

# Cleanup
echo "########################################"
echo "Cleaning up temporary files..."
echo "########################################"
echo
rm -rf /tmp/websitefiles
echo

echo "########################################"
echo "Deployment completed successfully."
echo "########################################"
echo
