#!/bin/bash
sudo apt -y update

echo '############## Baixando Projeto ################'

# sudo wget https://download.moodle.org/download.php/stable400/moodle-4.0.3.tgz
sudo mkdir -p /var/www/download
cd /var/www/download
sudo git clone -b MOODLE_400_STABLE git://git.moodle.org/moodle.git moodle
# sudo tar -xzf moodle-4.0.3.tgz -C /var/www/download/

sudo apt -y install nginx

sudo systemctl stop nginx.service
sudo systemctl start nginx.service
sudo systemctl enable nginx.service

sudo apt -y install php php-cli php-fpm php-json php-common zip unzip php7.4-imap php-mysql 
sudo apt -y install php-zip php-gd php-mbstring php-curl php-xml php-pear php-bcmath php-fileinfo
sudo apt -y install php-simplexml php-ldap php-apcu php-sodium

sudo apt-get install -y php7.4-intl php7.4-xmlrpc php7.4-soap

sudo apt install nfs-common -y
sudo apt-get -y install php7.4-fpm

curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

systemctl status php7.4-fpm nginx

echo '############## Removendo o Apache #################'

sudo systemctl disable --now apache2
sudo service apache2 stop
sudo /etc/init.d/apache2 stop
sudo apt-get purge -y apache2 apache2-utils apache2-bin apache2.2-common

echo '############## Configurando PHP #################'

sudo sed -i 's/max_execution_time = 30/max_execution_time = 600/g' /etc/php/7.4/fpm/php.ini
sudo sed -i 's/memory_limit = 128M/memory_limit = 64M/g' /etc/php/7.4/fpm/php.ini
sudo sed -i 's/;max_input_vars = 1000/max_input_vars = 6000/g' /etc/php/7.4/fpm/php.ini
sudo sed -i 's/;extension=exif/extension=exif/g' /etc/php/7.4/fpm/php.ini
sudo sed -i 's/;extension=xmlrpc/extension=xmlrpc/g' /etc/php/7.4/fpm/php.ini
sudo sed -i 's/;xmlrpc_errors = 0/xmlrpc_errors = 0/g' /etc/php/7.4/fpm/php.ini
sudo sed -i 's/;xmlrpc_error_number = 0/xmlrpc_error_number = 0/g' /etc/php/7.4/fpm/php.ini
sudo sed -i 's/;extension=intl/extension=intl/g' /etc/php/7.4/fpm/php.ini
sudo sed -i 's/;extension=soap/extension=soap/g' /etc/php/7.4/fpm/php.ini

sudo sed -i 's/;opcache.enable=1/opcache.enable=1/g' /etc/php/7.4/fpm/php.ini
sudo sed -i 's/;opcache.memory_consumption=128/opcache.memory_consumption=128/g' /etc/php/7.4/fpm/php.ini
sudo sed -i 's/;opcache.interned_strings_buffer=8/opcache.interned_strings_buffer=8/g' /etc/php/7.4/fpm/php.ini
sudo sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 100M/g' /etc/php/7.4/fpm/php.ini

# sudo sed -i 's/;extension=imap/extension=imap/g' /etc/php/7.4/fpm/php.ini
# sudo sed -i 's/short_open_tag = Off/short_open_tag = On/g' /etc/php/7.4/fpm/php.ini
# sudo sed -i 's/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g' /etc/php/7.4/fpm/php.ini
sudo sed -i 's/;date.timezone =/date.timezone=America\/Sao_Paulo/g' /etc/php/7.4/fpm/php.ini

sudo systemctl restart php7.4-fpm nginx


echo '############## Montando EFS ################'

# Aguarda 3 minutos para queo EFS seja criado
# sleep 3m

echo "${efs_id}"
echo "${region}"

# Usando do data template_file
efs_id="${efs_id}"
region="${region}"
sudo mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport $efs_id.efs.$region.amazonaws.com:/ /var/www/public/

echo '############## Copiando arquivos para o EFS ################'

sleep 3m

sudo mkdir -p /var/www/public/moodle
sudo mkdir -p /var/www/public/moodledata
cd /var/www/public/moodle/

sudo cp -R /var/www/download/moodle/. /var/www/public/moodle

echo '############## Atribuindo permissões ao arquivos do Projeto ################'

sudo chown -R www-data:www-data /var/www/public/moodle/
sudo chmod -R 0755 /var/www/public/moodle/

sudo chown -R www-data:www-data /var/www/public/moodledata/
sudo chmod -R 0755 /var/www/public/moodledata/

echo '############## Configurando Nginx ################'

PHP_INFO='<?php echo phpinfo(); ?>'

NGINX_INDEX='
    <!DOCTYPE html>
    <html>
    <head>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <meta http-equiv="refresh" content="3">
        <title>Porjeto</title>
    </head>
    <body>
    <h1>Aguarde a instalação do Porjeto...</h1>
    </body>
    </html>'

NGINX_CONFIG='server { \n  
    listen 80  default_server; \n  
    # listen [::]:80; \n  
 \n  
    root /var/www/public/moodle; \n  
    index  index.php index.html index.htm; \n  
 \n  
    server_name  _; \n  
 \n  
    client_max_body_size 100M; \n  
 \n  
    location / { \n    
        try_files $uri /index.php$is_args$args; \n    
    } \n
 \n  
    location ~ \.php$ { \n    
        include snippets/fastcgi-php.conf; \n    
        fastcgi_pass unix:/var/run/php/php7.4-fpm.sock; \n    
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name; \n    
        include fastcgi_params; \n  
    } \n
}'

# echo -e $NGINX_CONFIG > /etc/nginx/sites-available/default
echo -e $NGINX_CONFIG > /etc/nginx/sites-available/projeto

echo '############## Habilitando Rewrite Module ################'

sudo rm /etc/nginx/sites-enabled/default # Apagando o arquivo padrão
sudo ln -s /etc/nginx/sites-available/projeto /etc/nginx/sites-enabled/
# sudo systemctl restart nginx.service

sudo sed -i 's/keepalive_timeout 65;/keepalive_timeout 300;' /etc/nginx/nginx.conf

echo -e $NGINX_INDEX > /var/www/public/index.html

echo -e $PHP_INFO > /var/www/public/moodle/info.php # Não usar em produção

sudo systemctl restart nginx.service 


echo '############## Publicando SNS ###############'

echo Publicando SNS
topic_arn="${sns_topic_arn}"
aws sns publish --topic-arn $topic_arn --message "Implantação do Projeto finalizada."

# Adicionar ao config.php após a instalação via cli
# $CFG->sslproxy = true;