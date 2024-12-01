#!/bin/bash

# Backup sysctl.conf file
cp /etc/sysctl.conf /root/sysctl.conf_backup

# Configure sysctl.conf with desired settings
cat <<EOT> /etc/sysctl.conf
vm.max_map_count=262144
fs.file-max=131072
ulimit -n 131072
ulimit -u 8192
EOT

# Backup limits.conf file
cp /etc/security/limits.conf /root/sec_limit.conf_backup

# Configure limits.conf for SonarQube
cat <<EOT> /etc/security/limits.conf
sonarqube   -   nofile   131072
sonarqube   -   nproc    8192
EOT

# Update and install JDK
sudo apt-get update -y
sudo apt-get install openjdk-17-jdk -y
sudo update-alternatives --config java

# Check Java version
java -version

# Update system and add PostgreSQL repository
sudo apt update
wget -q https://www.postgresql.org/media/keys/ACCC4CF8.asc -O - | sudo apt-key add -
sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt/ `lsb_release -cs`-pgdg main" >> /etc/apt/sources.list.d/pgdg.list'

# Install PostgreSQL and start the service
sudo apt install postgresql postgresql-contrib -y
#sudo -u postgres psql -c "SELECT version();"
sudo systemctl enable postgresql.service
sudo systemctl start  postgresql.service

# Set PostgreSQL password for 'postgres' user
sudo echo "postgres:admin123" | chpasswd

# Create PostgreSQL user and database for SonarQube
runuser -l postgres -c "createuser sonar"
sudo -i -u postgres psql -c "ALTER USER sonar WITH ENCRYPTED PASSWORD 'admin123';"
sudo -i -u postgres psql -c "CREATE DATABASE sonarqube OWNER sonar;"
sudo -i -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE sonarqube to sonar;"

# Restart PostgreSQL service
systemctl restart  postgresql
#systemctl status -l   postgresql

# Install net-tools
sudo apt install net-tools
netstat -tulpena | grep postgres

# Download and install SonarQube
sudo mkdir -p /sonarqube/
cd /sonarqube/
# SonarQube Java 19 compatible version above V9
sudo curl -O https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-9.9.4.87374.zip
sudo apt-get install zip -y
sudo unzip -o sonarqube-9.9.4.87374.zip -d /opt/

# SonarQube Java 11 compatible version upto V8  https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-8.3.0.34182.zip
sudo mv /opt/sonarqube-9.9.4.87374/ /opt/sonarqube

# Create SonarQube group and user
sudo groupadd sonar
sudo useradd -c "SonarQube - User" -d /opt/sonarqube/ -g sonar sonar
sudo chown sonar:sonar /opt/sonarqube/ -R
cp /opt/sonarqube/conf/sonar.properties /root/sonar.properties_backup

# Configure SonarQube properties
cat <<EOT> /opt/sonarqube/conf/sonar.properties
sonar.jdbc.username=sonar
sonar.jdbc.password=admin123
sonar.jdbc.url=jdbc:postgresql://localhost/sonarqube
sonar.web.host=0.0.0.0
sonar.web.port=9000
sonar.web.javaAdditionalOpts=-server
sonar.search.javaOpts=-Xmx512m -Xms512m -XX:+HeapDumpOnOutOfMemoryError
sonar.log.level=INFO
sonar.path.logs=logs
EOT


# Configure SonarQube service
cat <<EOT> /etc/systemd/system/sonarqube.service
[Unit]
Description=SonarQube service
After=syslog.target network.target

[Service]
Type=forking

ExecStart=/opt/sonarqube/bin/linux-x86-64/sonar.sh start
ExecStop=/opt/sonarqube/bin/linux-x86-64/sonar.sh stop

User=sonar
Group=sonar
Restart=always

LimitNOFILE=65536
LimitNPROC=4096


[Install]
WantedBy=multi-user.target
EOT


# Reload systemd and enable SonarQube service
systemctl daemon-reload
systemctl enable sonarqube.service
#systemctl start sonarqube.service
#systemctl status -l sonarqube.service

# Install Nginx and configure SonarQube proxy
sudo apt-get install nginx -y
rm -rf /etc/nginx/sites-enabled/default
rm -rf /etc/nginx/sites-available/default
cat <<EOT> /etc/nginx/sites-available/sonarqube
server{
    listen      80;
    server_name sonarqube.groophy.in;

    access_log  /var/log/nginx/sonar.access.log;
    error_log   /var/log/nginx/sonar.error.log;

    proxy_buffers 16 64k;
    proxy_buffer_size 128k;

    location / {
        proxy_pass  http://127.0.0.1:9000;
        proxy_next_upstream error timeout invalid_header http_500 http_502 http_503 http_504;
        proxy_redirect off;
              
        proxy_set_header    Host            \$host;
        proxy_set_header    X-Real-IP       \$remote_addr;
        proxy_set_header    X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header    X-Forwarded-Proto http;
    }
}
EOT

# Enable Nginx and create symbolic link for SonarQube site
ln -s /etc/nginx/sites-available/sonarqube /etc/nginx/sites-enabled/sonarqube
systemctl enable nginx.service
#systemctl restart nginx.service

# Open ports in firewall
sudo ufw allow 80,9000,9001/tcp

# Reboot system after 30 seconds
echo "System reboot in 30 sec"
sleep 30
reboot
