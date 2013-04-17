#!/bin/bash  
 
# Starts the mongos servers 
# The step is executed concurrently on all mongos platforms 
  
# Define shards  
MONGOS_MAIN_PLATFORM=  
SHARD1_HOST=ec2-50-112-15-19.us-west-2.compute.amazonaws.com 
SHARD2_HOST=ec2-54-244-69-122.us-west-2.compute.amazonaws.com  
SHARD3_HOST=ec2-50-112-30-14.us-west-2.compute.amazonaws.com  
CONFIG_PORT=20001  
MONGOS_PORT=30000  
MONGOD_PORT=27018  
DATABASE_NAME=mongoTestStorage  
  
mkdir mongos  
killall -v mongos 
  
echo "Start Mongos server"  
mongos --port $MONGOS_PORT --configdb "$SHARD1_HOST":"$CONFIG_PORT","$SHARD2_HOST":"$CONFIG_PORT","$SHARD3_HOST":"$CONFIG_PORT" --fork --logpath mongos/mongos.log
