#!/bin/bash

# Install wget and unzip if not already installed
echo "########################################"
echo "Installing wget and unzip..."
echo "########################################"
echo
sudo apt-get update
sudo apt-get install -y wget unzip
echo

# Install apache and start and enable
echo "########################################"
echo "Installing and starting httpd..."
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
echo "Restarting httpd service..."
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
echo "Deployed completed successfully."
echo "########################################"
echo
