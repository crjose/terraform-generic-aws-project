#!/bin/bash
sudo apt -y update
sudo apt -y install unzip
sudo apt install locales-all && sudo locale-gen

# echo '############### Instalando NGINX ################'

# sudo apt -y install nginx

# sudo systemctl stop nginx.service
# sudo systemctl start nginx.service
# sudo systemctl enable nginx.service

# systemctl status nginx

echo '############### Instalando AWS CLI ################'

curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

echo '############### Instalando DOCKER ################'

sudo apt -y install docker.io
sudo apt -y install docker-compose

echo '############### Subino a aplicacao ################'

sudo mkdir -p /var/www/html
sudo mkdir -p /var/www/moodledata_data
sudo mkdir -p /home/ubuntu/devops

docker_compose="version: '2'\nservices:\n
%20moodle:\n
%20%20image: docker.io/bitnami/moodle:4\n
%20%20ports:\n
%20%20%20- '80:8080'\n
%20%20%20- '443:8443'\n
%20%20%20- '3306:3306'\n
%20%20environment:\n
%20%20%20- MOODLE_DATABASE_HOST=RDS_DNS\n
%20%20%20- MOODLE_DATABASE_PORT_NUMBER=3306\n
%20%20%20- MOODLE_DATABASE_USER=projetoadmin\n
%20%20%20- MOODLE_DATABASE_NAME=oficinadb\n
%20%20%20- MOODLE_DATABASE_PASSWORD=Projeto2022Oficina\n
%20%20%20- MOODLE_DATABASE_TYPE=auroramysql\n
%20%20volumes:\n
%20%20%20- /var/www/html:/bitnami/moodle\n
%20%20%20- /var/www/moodledata_data:/bitnami/moodledata\n
%20%20networks:\n
%20%20%20- code-network\n
%20%20restart: always\n\nnetworks:\n
%20%20code-network:\n
%20%20%20%20driver: bridge\n
"

echo '############### Variaveis ################'

efs_id="${efs_id}"
region="${region}"
rds="${rds_addr}"

echo -e $docker_compose > /home/ubuntu/devops/docker-compose.yml

echo "---> RDS DNS"
echo $rds
echo "---> EFS"
echo $efs_id
echo "---> REGION "
echo $region
echo "---> REGION "

sudo sed -i "s/RDS_DNS/$rds/g" /home/ubuntu/devops/docker-compose.yml
sudo sed -i 's/%20/ /g' /home/ubuntu/devops/docker-compose.yml

cd /home/ubuntu/devops/

sudo docker-compose up --build -d

echo '############### Publicando SNS ################'

echo Publicando SNS
topic_arn="${sns_topic_arn}"
aws sns publish --topic-arn $topic_arn --message "Implantação do Projeto finalizada."

