#!/bin/bash

# quick prepping AWS nodes for cassandra 3.x tests

FILESYSTEM_TYPE=$1
HOST_IP=$(curl http://169.254.169.254/latest/meta-data/local-ipv4)
SEED_ONE=$2
SEED_TWO=$3

# prepare /mnt 
mkfs -t $FILESYSTEM_TYPE /dev/xvdb 
mv /mnt /tmp && sudo mkdir /mnt
mount /dev/xvdb /mnt && sudo mv /tmp/mnt/* /mnt && sudo rm -rf /tmp/mnt
df -h # verify /mnt is the mountpoint for xcdb

# prepare for yum
echo -e "[datastax-ddc]\nname = DataStax Repo for Apache Cassandra\nbaseurl = http://rpm.datastax.com/datastax-ddc/3.2\nenabled = 1\ngpgcheck = 0" > /etc/yum.repos.d/datastax.repo
install cassandra
yum install datastax-ddc

# prep cassandra dirs
mkdir -p /mnt/cassandra/commitlog
mkdir -p /mnt/cassandra/saved_caches
mkdir -p /mnt/cassandra/hints
mkdir -p /mnt/cassandra/data
chown -R cassandra:cassandra /mnt/cassandra/
chown -R cassandra:cassandra /var/lib/cassandra/

# prep cassandra.yaml
sed -i "s/rpc_address:.*/rpc_address: 0\.0\.0\.0/g" /etc/cassandra/conf/cassandra.yaml
sed -i "s/- seeds.*$/- seeds: \"$SEED_ONE,$SEED_TWO\"/g" /etc/cassandra/conf/cassandra.yaml
sed -i '/data_file_directories:/s/# //g' /etc/cassandra/conf/cassandra.yaml
sed -i '/#[[:space:]]*- \/var\/lib\/cassandra\/data$/{s/# //g;s/\/var\/lib\/cassandra\/data$/\/mnt\/cassandra\/data/g;}' /etc/cassandra/conf/cassandra.yaml
sed -i '/#[[:space:]].* \/var\/lib\/cassandra\/commitlog$/{s/# //g;s/\/var\/lib\/cassandra\/commitlog$/\/mnt\/cassandra\/commitlog/g;}' /etc/cassandra/conf/cassandra.yaml
sed -i '/#[[:space:]].* \/var\/lib\/cassandra\/saved_caches$/{s/# //g;s/\/var\/lib\/cassandra\/saved_caches$/\/mnt\/cassandra\/saved_caches/g;}' /etc/cassandra/conf/cassandra.yaml
sed -i '/#[[:space:]].* \/var\/lib\/cassandra\/hints$/{s/# //g;s/\/var\/lib\/cassandra\/hints$/\/mnt\/cassandra\/hints/g;}' /etc/cassandra/conf/cassandra.yaml
sed -i "s/listen_address: localhost$/listen_address: $HOST_IP/g" /etc/cassandra/conf/cassandra.yaml
sed -i '/start_rpc: false$/s/false$/true/g' /etc/cassandra/conf/cassandra.yaml
sed -i "s/#[[:space:]].* broadcast_rpc_address.*$/broadcast_rpc_address: $HOST_IP/g" /etc/cassandra/conf/cassandra.yaml
sed -i '/endpoint_snitch:/s/SimpleSnitch/Ec2Snitch/g' /etc/cassandra/conf/cassandra.yaml

# prep cassandra-env.sh
cp /etc/cassandra/conf/cassandra-env.sh /etc/cassandra/conf/cassandra-env.sh.bak
vim /etc/cassandra/conf/cassandra-env.sh -c ":228" -c "normal 3dd" -i "normal i LOCAL_JMX=no"

# ensure cassandra user's env provides java 1.8
echo -e "export JAVA_HOME=/opt/java/1.8.0_40\nexport PATH=\$PATH:/opt/java/1.8.0_40" > /etc/profile.d/jdk.sh
su - cassandra
