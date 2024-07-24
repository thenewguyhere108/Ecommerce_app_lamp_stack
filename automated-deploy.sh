#!/bin/bash

# Script to deploy a three tier web application

# Installing the necessary pacakges beforehand 
echo " Installing the necessary packages"

sudo yum install -y firewalld mariadb-server httpd php php-mysqlnd git

# Starting the firewall service
echo "Starting firewall services"
sudo systemctl start firewalld
sudo systemctl enable firewalld
sudo systemctl status firewalld


# Starting and configuring the database service"
echo "Starting Mariadb service"
sudo systemctl start mariadb
sudo systemctl enable mariadb

echo "Configure firewall for database"
sudo firewall-cmd --permanent --zone=public --add-port=3306/tcp
sudo firewall-cmd --reload

# Creating and running a sql script to initialize the database"
echo "Configure Database"
cat > setup-db.sql <<-EOF
  CREATE DATABASE ecomdb;
  CREATE USER 'ecomuser'@'localhost' IDENTIFIED BY 'ecompassword';
  GRANT ALL PRIVILEGES ON *.* TO 'ecomuser'@'localhost';
  FLUSH PRIVILEGES;
EOF
sudo mysql < setup-db.sql

# Loading data into the DB
echo "Loading inventory into the database"
cat > db-load-script.sql <<-EOF
USE ecomdb;
CREATE TABLE products (id mediumint(8) unsigned NOT NULL auto_increment,Name varchar(255) default NULL,Price varchar(255) default NULL, ImageUrl varchar(255) default NULL,PRIMARY KEY (id)) AUTO_INCREMENT=1;

INSERT INTO products (Name,Price,ImageUrl) VALUES ("Laptop","100","c-1.png"),("Drone","200","c-2.png"),("VR","300","c-3.png"),("Tablet","50","c-5.png"),("Watch","90","c-6.png"),("Phone Covers","20","c-7.png"),("Phone","80","c-8.png"),("Laptop","150","c-4.png");

EOF

sudo mysql < db-load-script.sql

echo " Database setup completed"

# Setting up the apache http server
echo "Webserver Initilizing"
echo "Configure firewall for webserver"
sudo firewall-cmd --permanent --zone=public --add-port=80/tcp
sudo firewall-cmd --reload
echo "Update http server to use php"
sudo sed -i 's/index.html/index.php/g' /etc/httpd/conf/httpd.conf
echo "Cloning website into the directory"
sudo git clone https://github.com/kodekloudhub/learning-app-ecommerce.git /var/www/html/
echo "update ip address in php"
sudo sed -i 's#// \(.*mysqli_connect.*\)#\1#' /var/www/html/index.php
sudo sed -i 's#// \(\$link = mysqli_connect(.*172\.20\.1\.101.*\)#\1#; s#^\(\s*\)\(\$link = mysqli_connect(\$dbHost, \$dbUser, \$dbPassword, \$dbName);\)#\1// \2#' /var/www/html/index.php
sudo sed -i 's/172.20.1.101/localhost/g' /var/www/html/index.php
echo "Starting the webserver"
sudo systemctl start httpd
sudo systemctl enable httpd
echo "Sucessfully deployed"