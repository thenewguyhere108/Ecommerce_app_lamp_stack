# LAMP_Stack_Deploy
This is a bash script to automatically deploy a LAMP stack application

The script targets mainly centos.
The application used in the script is fron https://github.com/kodekloudhub/learning-app-ecommerce


The bash script installs firewalld, mariadb, apache server git and php.
It then creates firewall rules for db and webserver.
It creates mysql scripts to load the database.
It configures the apache server and finally starts it.
