#!/bin/bash  
 
# Create a database shard node and downloads the shards connection parameters on the local server.This script should run on the rundeck local server.
# SHARDS_NUMBER and HDD_SIZE are defined as rundeck options.  

PROVISIONR_HOST=localhost 
PROVISIONR_PORT=8181 
PROVISIONR_PATH=/home/tudor/repos/incubator-provisionr/karaf/assembly/target/org.apache.provisionr-0.4.0-incubating-SNAPSHOT/bin/ 
RAND=$(( $RANDOM % 100000 ))
SHARDS_KEY=s${RAND} 
SHARDS_NUMBER=@option.SHARDS_NUMBER@
HDD_SIZE=@option.HDD_SIZE@
${PROVISIONR_PATH}client "provisionr:create --id amazon --key ${SHARDS_KEY} --size ${SHARDS_NUMBER} --volume /dev/sdh1:${HDD_SIZE} --volume /dev/sdh2:${HDD_SIZE} --volume /dev/sdh3:${HDD_SIZE} --volume /dev/sdh4:${HDD_SIZE} --hardware-type m1.large --template mongod --image-id ami-4965f479 --timeout 1200" 
 
# wait 5 minutes for the instances to be created 
sleep 300 
 
# get the shards machine.xml file 
 
rm -rf shards.xml 
wget http://${PROVISIONR_HOST}:${PROVISIONR_PORT}/rundeck/machines.xml -O shards.xml
