docker rm $(docker ps -a -q) -f

sudo docker run -td --name=testing -p 127.0.0.1:80:80 ubuntu:14.04
sudo docker cp autoSetup.txt testing:/
sudo docker exec testing apt-get update
sudo docker exec testing apt-get -y install openssh-client
sudo docker exec testing apt-get -y install curl
echo
sudo docker exec -it testing /bin/bash
