#!/bin/bash 
 
# Configure the mongos stations 2.Enable sharding on DATABASE_NAME, and sets the sharding key for blobs and nodes collections.
 
MONGOS_MAIN=`xmllint --xpath 'string(/project/node[1]/@hostname)' mongos.xml` 
CURRENT_NODE=$1
MONGOS_PORT=27017 
MONGOD_PORT=27017 
DATABASE_NAME=Oak 
# get shards Ips 
 
TEMP=`xmllint --xpath '/project/node/@hostname' shards.xml|sed -e "s/ hostname=/ /g"| sed -e "s/\"/'/g"` 
declare -a shards=($TEMP) 
 
 
 
# configure the cluster from the main platform 
if [ "$CURRENT_NODE" == "$MONGOS_MAIN" ]; then 
	echo MONGOS $MONGOS_MAIN starting to configure the shards 
	for shard in "${shards[@]}" 
	do 
	  shard_trim=`echo $shard|tr -d ''\'''` 
	  echo "Link shard:sh.addShard(\"${shard_trim}:${MONGOD_PORT}\")" 
	  mongo --host $MONGOS_MAIN admin --port $MONGOS_PORT --eval "sh.addShard(\"${shard_trim}:${MONGOD_PORT}\")" 
	  sleep 2 
	done 
	mongo --host $MONGOS_MAIN $DATABASE_NAME --port $MONGOS_PORT --eval "sh.enableSharding(\"$DATABASE_NAME\")" 
	# Set sharding key for nodes and blobs 
	mongo --host $MONGOS_MAIN $DATABASE_NAME --port $MONGOS_PORT --eval "db.createCollection(\"nodes\", {})"
	mongo --host $MONGOS_MAIN $DATABASE_NAME --port $MONGOS_PORT --eval "db.createCollection(\"blobs\", {})"  
	mongo --host $MONGOS_MAIN $DATABASE_NAME --port $MONGOS_PORT --eval "sh.shardCollection(\"$DATABASE_NAME.nodes\", { \"_id\": 1 }, true)" 
	mongo --host $MONGOS_MAIN $DATABASE_NAME --port $MONGOS_PORT --eval "sh.shardCollection(\"$DATABASE_NAME.blobs\", { \"_id\": 1 }, true)" 
fi
