#!/bin/bash

#set -x

set -e

sudo apt-get update

sudo apt-get --yes --quiet install ntp
date

sudo DEBIAN_FRONTEND=noninteractive apt-get --yes --quiet install mysql-server mysql-client libmysql-java
#mysqladmin --user=root password foobar

sudo service mysql stop
sudo sed --in-place=.orig --expression='s/^bind-address.*$/bind-address=0.0.0.0/' /etc/mysql/my.cnf
sudo service mysql start
sudo service mysql status

mysql --user=root --password=foobar <<"EOT"
#create database DroidChat;
#create user 'droid'@'localhost' identified by 'droid';
grant all on DroidChat.* to 'droid'@'localhost';
flush privileges;
EOT
mysql --user=droid --password=droid --table --execute='show databases;' DroidChat

sudo apt-get --yes --quiet install openjdk-7-jre-headless
java -version

sudo apt-get --yes --quiet install tomcat7 tomcat7-admin
#(cd /usr/share/tomcat7/lib; sudo ln -s ../../java/mysql.jar)
sudo service tomcat7 status

sudo apt-get --yes -- quiet install nginx
sudo service nginx stop

sudo rm /etc/nginx/sites-enabled/*
sudo mv /etc/nginx/sites-available/default /etc/nginx/sites-available/default.orig
sudo bash -c 'cat > /etc/nginx/sites-available/default'<<"EOT"
server {
    listen 80;
    location / {
      client_max_body_size    100M;
      client_body_buffer_size 1M;
      proxy_read_timeout      720s;
      proxy_set_header  X-Forwarded-Host      $host;
      proxy_set_header  X-Forwarded-Server    $host;
      proxy_set_header  X-Forwarded-For       $proxy_add_x_forwarded_for;
      proxy_set_header  Host  $host;
      proxy_pass        http://127.0.0.1:8080;
    }
}
EOT
sudo ln -s /etc/nginx/sites-available/default /etc/nginx/sites-enabled/default

sudo service nginx start
sudo service nginx status

      
