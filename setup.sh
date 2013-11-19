#!/bin/bash

#set -x

set -e

sudo apt-get update

sudo apt-get --yes --quiet install ntp

mysql DEBIAN FRONTEND=noninteractive apt-get --yes --quiet install mysql-server mysql-client libmysql-java
mysqladmin --user=root password foobar

sudo service msql stop
sudo sed --in-place=.orig --expression='s/^bind-address.*$/bind-address=0.0.0.0/' /etc/mysql/my.cnf
sudo service mysql start
sudo service mysql status

mysql --user=root --password=foobar <<"EOT"
create database DroidChat;
create user 'droid'@'localhost' indetified by 'droid';
grant all on DroidChat.* to 'droid'@'localhost';
flush privileges;
EOT
mysql --user=droid --passord=droid --table --execute='show databases;' DroidChat

