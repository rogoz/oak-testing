#!/bin/bash

MONGOS_MAIN_PLATFORM=`xmllint --xpath 'string(/project/node[1]/@hostname)' mongos.xml`
DATABASE_NAME=Oak
MONGOS_PORT=27017

if [ "$CURRENT_NODE" == "$MONGOS_MAIN" ]; then
 mongo --host localhost $DATABASE_NAME --port $MONGOS_PORT --eval "db.nodes.remove()" 
 mongo --host localhost $DATABASE_NAME --port $MONGOS_PORT --eval "db.segments.remove()"     
 mongo --host localhost $DATABASE_NAME --port $MONGOS_PORT --eval "db.results.remove()"  
 mongo --host localhost $DATABASE_NAME --port $MONGOS_PORT --eval "db.summary.remove()"     
 mongo --host localhost $DATABASE_NAME --port $MONGOS_PORT --eval "db.journals.remove()"
 mongo --host localhost $DATABASE_NAME --port $MONGOS_PORT --eval "db.syncOAK.remove()"
fi
