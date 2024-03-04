#!/bin/bash

# Declaring Variables
URL="https://www.tooplate.com/zip-templates/2137_barista_cafe.zip"
FILE_NAME="2137_barista_cafe"
FILE_TYPE="zip"
TEMP_DIR="/tmp/websitefiles"
APACHE_DOC_ROOT="/var/www/html/"

# Install wget and unzip if not already installed
echo "########################################"
echo "Installing wget and unzip..."
echo "########################################"
echo
sudo apt-get update > /dev/null
sudo apt-get install -y wget unzip > /dev/null
echo

# Install apache2 and start and enable
echo "########################################"
echo "Installing and starting apache2..."
echo "########################################"
echo
sudo apt-get install -y apache2 > /dev/null
sudo systemctl start apache2
sudo systemctl enable apache2
echo

# Creating temp directory /tmp/websitefiles
echo "########################################"
echo "Creating temporary directory and downloading website files..."
echo "########################################"
echo
mkdir -p $TEMP_DIR
cd $TEMP_DIR
wget $URL
unzip $FILE_NAME.$FILE_TYPE > /dev/null
echo

# Copying files to Apache's document root
echo "########################################"
echo "Copying files to Apache's document root..."
echo "########################################"
echo
sudo cp -r $FILE_NAME/* $APACHE_DOC_ROOT > /dev/null
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
rm -rf $TEMP_DIR
echo

echo "########################################"
echo "Deployment completed successfully."
echo "########################################"
echo
