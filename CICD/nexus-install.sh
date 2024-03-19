#!/bin/bash

# Install Java and wget
apt update
apt install openjdk-8-jdk -y
apt install wget -y

# Create directories
mkdir -p /opt/nexus/
mkdir -p /tmp/nexus/

cd /tmp/nexus/

# Download Nexus
NEXUSURL="https://download.sonatype.com/nexus/3/latest-unix.tar.gz"
wget $NEXUSURL -O nexus.tar.gz

sleep 10

# Extract Nexus
EXTOUT=$(tar xzvf nexus.tar.gz)
NEXUSDIR=$(echo "$EXTOUT" | head -n 1 | cut -d '/' -f1)

sleep 5

# Clean up
rm -rf /tmp/nexus/nexus.tar.gz

# Move Nexus to installation directory
cp -r /tmp/nexus/* /opt/nexus/

sleep 5

# Create nexus user
useradd nexus
chown -R nexus:nexus /opt/nexus

# Create systemd service file
cat <<EOT>> /etc/systemd/system/nexus.service
[Unit]
Description=nexus service
After=network.target

[Service]
Type=forking
LimitNOFILE=65536
ExecStart=/opt/nexus/$NEXUSDIR/bin/nexus start
ExecStop=/opt/nexus/$NEXUSDIR/bin/nexus stop
User=nexus
Restart=on-abort

[Install]
WantedBy=multi-user.target
EOT

# Configure nexus user in nexus.rc
echo 'run_as_user="nexus"' > /opt/nexus/$NEXUSDIR/bin/nexus.rc

# Reload systemd daemon
systemctl daemon-reload

# Start Nexus service
systemctl start nexus

# Enable Nexus service to start on boot
systemctl enable nexus
