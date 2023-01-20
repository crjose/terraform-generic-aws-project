#!/bin/bash

echo "########################################"
echo "###### Instalação do PHP e Apache ######"
echo "########################################"

sudo add-apt-repository ppa:ondrej/php -y

sudo apt update

sudo apt install apache2 apache2-utils mariadb-client \
    php7.4 libapache2-mod-php7.4 php7.4-mysql php-common php7.4-cli \
    php7.4-common php7.4-json php7.4-opcache php7.4-readline php7.4-bcmath \
    php7.4-curl php7.4-fpm php7.4-gd php7.4-xml php7.4-mbstring unzip -y 

sudo echo "<?php phpinfo();" | sudo tee /var/www/html/info.php

sudo systemctl restart apache2

echo '##### INSTALANDO O AWS CLI #####'

cd /home/ubuntu
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

echo '############### Publicando SNS ################'

echo Publicando SNS
topic_arn="${sns_topic_arn}"
aws sns publish --topic-arn $topic_arn --message "Implantação do Projeto finalizada."

echo "################# FIM ###################"