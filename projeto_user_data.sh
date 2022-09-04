#!/bin/bash

sudo apt update
sudo apt -y install docker.io
sudo apt -y install docker-compose

sudo mkdir -p /var/www/html
sudo mkdir -p /var/www/moodledata_data
sudo mkdir -p /home/ubuntu/devops

docker_compose="${docker_compose}"
efs_id="${efs_id}"
region="${region}"
rds_dns="${rds_dns}"

docker_compose_parsed=$(echo "$docker_compose" | sed "s/RDS_DNS/$rds_dns")

sudo mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport $efs_id.efs.$region.amazonaws.com:/ /var/www/public/

sleep 3m

echo -e $docker_compose_parsed > /home/ubuntu/devops/docker-compose.yml

cd /home/ubuntu/devops

sudo docker-compose up --build -d

echo '############## Publicando SNS ###############'

echo Publicando SNS
topic_arn="${sns_topic_arn}"
aws sns publish --topic-arn $topic_arn --message "Implantação do Projeto finalizada."