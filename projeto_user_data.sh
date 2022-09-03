sudo apt update
sudo apt -y install docker.io
sudo apt -y install docker-compose

sudo mkdir -p /var/www/html
sudo mkdir -p /var/www/moodledata_data
sudo mkdir -p /home/ubuntu/devops

efs_id="${efs_id}"
region="${docker_compose}"
docker_compose="${docker_compose}"

echo -e $docker_compose > /home/ubuntu/devops/docker-compose.yml