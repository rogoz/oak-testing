#!/bin/bash

# Configure the shards.The script must run on each shard.


MONGOD_LOG_PATH="logpath=/log/mongod.log"
MONGOD_APPEND_LOG="logappend=true"
MONGOD_FORK="fork=true"
MONGOD_DBPATH="dbpath=/data"
MONGOD_SHARD="shardsvr = true"


# configure RAID
sudo mdadm --verbose --create /dev/md0 --level=10 --chunk=256 --raid-devices=4 /dev/xvdh1 /dev/xvdh2 /dev/xvdh3 /dev/xvdh4
echo 'DEVICE /dev/xvdh1 /dev/xvdh2 /dev/xvdh3 /dev/xvdh4' | sudo tee -a /etc/mdadm.conf
sudo mdadm --detail --scan | sudo tee -a /etc/mdadm.conf

sudo blockdev --setra 128 /dev/md0
sudo blockdev --setra 128 /dev/xvdh1
sudo blockdev --setra 128 /dev/xvdh2
sudo blockdev --setra 128 /dev/xvdh3
sudo blockdev --setra 128 /dev/xvdh4

sudo dd if=/dev/zero of=/dev/md0 bs=512 count=1
sudo pvcreate /dev/md0
sudo vgcreate vg0 /dev/md0

sudo lvcreate -l 80%vg -n data vg0
sudo lvcreate -l 5%vg -n log vg0
sudo lvcreate -l 15%vg -n journal vg0

sudo mke2fs -t ext4 -F /dev/vg0/data
sudo mke2fs -t ext4 -F /dev/vg0/log
sudo mke2fs -t ext4 -F /dev/vg0/journal

sudo mkdir /data
sudo mkdir /log
sudo mkdir /journal

echo '/dev/vg0/data /data ext4 defaults,auto,noatime,noexec 0 0' | sudo tee -a /etc/fstab
echo '/dev/vg0/log /log ext4 defaults,auto,noatime,noexec 0 0' | sudo tee -a /etc/fstab
echo '/dev/vg0/journal /journal ext4 defaults,auto,noatime,noexec 0 0' | sudo tee -a /etc/fstab

sudo mount /data
sudo mount /log
sudo mount /journal
sudo mkdir /data/db
sudo ln -s /journal /data/db/journal
#install mongo

sudo apt-key adv --keyserver keyserver.ubuntu.com --recv 7F0CEB10
echo 'deb http://downloads-distro.mongodb.org/repo/ubuntu-upstart dist 10gen' | sudo tee /etc/apt/sources.list.d/10gen.list
sudo apt-get update
sudo apt-get install mongodb-10gen
# close all mongod processes

sudo mongo --eval "db.getSiblingDB('admin').shutdownServer()"
sudo killall -v mongod

# configure mongod file
echo $MONGOD_LOG_PATH | sudo tee /etc/mongod.conf
echo $MONGOD_APPEND_LOG | sudo tee -a /etc/mongod.conf
echo $MONGOD_FORK | sudo tee -a /etc/mongod.conf
echo $MONGOD_DBPATH | sudo tee -a /etc/mongod.conf
echo $MONGOD_SHARD | sudo tee -a /etc/mongod.conf

# start mongod node
sudo nohup mongod >& /dev/null &

# start config node
sudo mkdir ~/config/
sudo nohup mongod --configsvr --port 20001 --dbpath=config --logpath config/config.log >& /dev/null &



