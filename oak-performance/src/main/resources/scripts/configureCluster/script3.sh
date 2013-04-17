#!/bin/bash  
 
# Drops the $DATABASE_NAME on each shard 
# Adds each shard to the cluster 
# Creates the NODES, segments, blobs, syncOAK collections 
# Enable sharding for the $DATABASE_NAME 
# Sets sharding keys for NODES, segments, syncOAK collections 
# The step is executed ONLY on the MONGOS_MAIN_PLATFORM 
 
# Define shards  
SHARD1_HOST=ec2-50-112-15-19.us-west-2.compute.amazonaws.com 
SHARD2_HOST=ec2-54-244-69-122.us-west-2.compute.amazonaws.com  
SHARD3_HOST=ec2-50-112-30-14.us-west-2.compute.amazonaws.com  
CONFIG_PORT=20001  
MONGOS_PORT=30000  
MONGOD_PORT=27018  
CURRENT_NODE=@node.hostname@  
MONGOS_MAIN_PLATFORM=@option.MONGOS_MAIN_PLATFORM@  
DATABASE_NAME=mongoTestStorage  
 
  
if [ "$CURRENT_NODE" == "$MONGOS_MAIN_PLATFORM" ]; then  
  echo "Drop database on each shard"  
  mongo --host $SHARD1_HOST $DATABASE_NAME --port $MONGOD_PORT --eval "db.dropDatabase()"  
  mongo --host $SHARD2_HOST $DATABASE_NAME --port $MONGOD_PORT --eval "db.dropDatabase()"  
  mongo --host $SHARD3_HOST $DATABASE_NAME --port $MONGOD_PORT --eval "db.dropDatabase()"  
  echo "Link shards"  
  mongo --host $MONGOS_MAIN_PLATFORM admin --port $MONGOS_PORT  --eval "sh.addShard(\"$SHARD1_HOST:$MONGOD_PORT\")"  
  mongo --host $MONGOS_MAIN_PLATFORM admin --port $MONGOS_PORT  --eval "sh.addShard(\"$SHARD2_HOST:$MONGOD_PORT\")"  
  mongo --host $MONGOS_MAIN_PLATFORM admin --port $MONGOS_PORT  --eval "sh.addShard(\"$SHARD3_HOST:$MONGOD_PORT\")"  
  echo "Create collections"  
  mongo --host $MONGOS_MAIN_PLATFORM $DATABASE_NAME --port $MONGOS_PORT --eval "db.createCollection(\"NODES\")"  
  mongo --host $MONGOS_MAIN_PLATFORM $DATABASE_NAME --port $MONGOS_PORT --eval "db.createCollection(\"blobs\")"  
  mongo --host $MONGOS_MAIN_PLATFORM $DATABASE_NAME --port $MONGOS_PORT --eval "db.createCollection(\"segments\")"  
  mongo --host $MONGOS_MAIN_PLATFORM $DATABASE_NAME --port $MONGOS_PORT --eval "db.createCollection(\"syncOAK\")"  
  echo "Enable sharding"  
  mongo --host $MONGOS_MAIN_PLATFORM $DATABASE_NAME --port $MONGOS_PORT --eval "sh.enableSharding(\"$DATABASE_NAME\")"  
  echo "Set sharding key"  
  mongo --host $MONGOS_MAIN_PLATFORM $DATABASE_NAME --port $MONGOS_PORT --eval "sh.shardCollection(\"$DATABASE_NAME.NODES\", { \"_id\": 1 }, true)"  
  mongo --host $MONGOS_MAIN_PLATFORM $DATABASE_NAME --port $MONGOS_PORT --eval "sh.shardCollection(\"$DATABASE_NAME.segments\", { \"_id\": 1 }, true)"  
  mongo --host $MONGOS_MAIN_PLATFORM $DATABASE_NAME --port $MONGOS_PORT --eval "sh.shardCollection(\"$DATABASE_NAME.syncOAK\", { \"_id\": 1 }, true)"  
fi
