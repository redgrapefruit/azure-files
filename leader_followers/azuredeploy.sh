#!/bin/sh

# This script can be found on https://github.com/manabuishii/azure-files/blob/master/leader_followers/azuredeploy.sh
# This script is part of azure deploy ARM template
# This script assumes the Linux distribution to be Ubuntu (or at least have apt-get support)

# Basic info
date > /tmp/azuredeploy.log.$$ 2>&1
whoami >> /tmp/azuredeploy.log.$$ 2>&1
echo $@ >> /tmp/azuredeploy.log.$$ 2>&1

echo "Hello [$1] world" > /tmp/helloworld.txt.$$ 2>&1
curl -L https://www.opscode.com/chef/install.sh | sudo bash -s -- -P chefdk -v 1.2.20 > /tmp/chef.txt.$$ 2>&1

sudo apt-get update
sudo apt-get install -y git

chef gem install knife-solo -v 0.6.0


cd /tmp
mkdir gridengine
cd gridengine/
git clone https://github.com/manabuishii/azure-files.git .
cd leader_followers/chef

id > /tmp/setting.txt.$$ 2>&1
set >> /tmp/setting.txt.$$ 2>&1
echo "HOME=[$HOME]" >> /tmp/setting.txt.$$ 2>&1
echo "HOSTNAME=[$HOSTNAME]" >> /tmp/setting.txt.$$ 2>&1

HOME=/root berks vendor cookbooks  > /tmp/berks.txt.$$ 2>&1

if [ ${HOSTNAME} == "master" ];
then
  chef-client -j environments/master.json -z   > /tmp/chef-master.txt.$$ 2>&1
else
  chef-client -j environments/exec.json -z  > /tmp/chef-client.txt.$$ 2>&1
  /etc/init.d/gridengine-exec stop  >> /tmp/chef-client.txt.$$ 2>&1
  /etc/init.d/gridengine-exec start >> /tmp/chef-client.txt.$$ 2>&1
fi

exit 0