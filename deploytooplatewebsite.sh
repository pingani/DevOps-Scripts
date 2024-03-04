#!/bin/bash

# Step 1: Install wget and unzip if not already installed
echo "Step 1: Installing wget and unzip..."
sudo apt-get update
sudo apt-get install -y wget unzip

# Step 2: Install httpd and start and enable
echo "Step 2: Installing and starting httpd..."
sudo apt-get install -y apache2
sudo systemctl start apache2
sudo systemctl enable apache2

# Step 3: Creating temp directory /tmp/websitefiles
echo "Step 3: Creating temporary directory and downloading website files..."
mkdir -p /tmp/websitefiles
cd /tmp/websitefiles
wget https://www.tooplate.com/zip-templates/2135_mini_finance.zip
unzip 2135_mini_finance.zip

# Step 4: Copying files to Apache's document root
echo "Step 4: Copying files to Apache's document root..."
sudo cp -r 2135_mini_finance/* /var/www/html/

# Step 5: Restart httpd service
echo "Step 5: Restarting httpd service..."
sudo systemctl restart apache2

# Step 6: Cleanup
echo "Step 6: Cleaning up temporary files..."
rm -rf /tmp/websitefiles

echo "Setup completed successfully."
