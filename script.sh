#!/bin/bash

echo "//////////////////////  Installation paquets APT   //////////////////////////"

apt update
apt install -y mariadb-server mariadb-client
apt install -y php apache2 libapache2-mod-php php-mysql php-xml
apt install -y composer vim git snapd

echo "/////////////////////   config snapd + certbot   /////////////////////////"
snap install core
snap refresh core
snap install --classic certbot

echo "/////////////////////////   CERTBOT   //////////////////////"

CERTBOT=$(ls /usr/bin | grep certbot)

if [ -z "$CERTBOT" ]
then
	ln -s /snap/bin/certbot /usr/bin/certbot
fi

echo "/////////////////////////   Test md5sum   //////////////////////////////"

MD5_SRC=$(md5sum 000-default.conf | awk '{print $1}')
MD5_DEST=$(md5sum /etc/apache2/sites-available/000-default.conf | awk '{print $1}')

if [ "$MD5_DEST" != "$MD5_SRC" ]
then
	echo "ils sont differents donc j'ecrase le fichier"
	cp 000-default.conf /etc/apache2/sites-available/000-default.conf
	service apache2 restart
fi

mkdir /var/www/html

echo "////////////////////   Pull sources git   ///////////////////////////////"

VERIFY_GIT=$(ls /var/www/html | grep .git)

if [ -z "$VERIFY_GIT" ]
then
	ln -s /var/www/html/.git https://github.com/AnthonyClet/Script-serv-conf.git
fi

cd /var/www/html
git pull origin master
composer install
chown -R www-data:www-data /var/www/html/
source .env.dev

echo "penser a taper la commande : certbot --apache"
