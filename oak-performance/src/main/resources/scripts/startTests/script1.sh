#!/bin/bash     
    
# Removes the documents from syncOAK, NODES and segments collection    
# Launches the test (@option.TestName@) on each platform    
# The step is executed concurrently on all mongos platforms    
    
export JAVA_HOME=/home/$USER/jdk1.6.0_33/      
export PATH=${JAVA_HOME}bin:$PATH     
export M2=/home/$USER/maven/bin     
export MAVEN_OPTS="-Xmx512m -XX:MaxPermSize=128m"     
export PATH=$PATH:$M2     
     
SHARD1_HOST=ec2-50-112-15-19.us-west-2.compute.amazonaws.com    
SHARD2_HOST=ec2-54-244-69-122.us-west-2.compute.amazonaws.com     
SHARD3_HOST=ec2-50-112-30-14.us-west-2.compute.amazonaws.com     
MONGOS_MAIN_PLATFORM=@option.MONGOS_MAIN_PLATFORM@    
CONFIG_PORT=20001     
MONGOS_PORT=30000     
MONGOD_PORT=27018     
CURRENT_NODE=@node.hostname@      
MONGOS_MAIN_PLATFORM=@option.MONGOS_MAIN_PLATFORM@     
DATABASE_NAME=mongoTestStorage     
CLUSTER_NODE_ID=${CURRENT_NODE:0:15}     
PROCESS_TIMEOUT=30  
   
killall -v java   
if [ "$CURRENT_NODE" == "$MONGOS_MAIN_PLATFORM" ]; then     
    # clean collections   
    mongo --host $MONGOS_MAIN_PLATFORM $DATABASE_NAME --port $MONGOS_PORT --eval "db.syncOAK.remove()"     
    mongo --host $MONGOS_MAIN_PLATFORM $DATABASE_NAME --port $MONGOS_PORT --eval "db.NODES.remove()"     
    mongo --host $MONGOS_MAIN_PLATFORM $DATABASE_NAME --port $MONGOS_PORT --eval "db.nodes.remove()" 
    mongo --host $MONGOS_MAIN_PLATFORM $DATABASE_NAME --port $MONGOS_PORT --eval "db.segments.remove()"     
    mongo --host $MONGOS_MAIN_PLATFORM $DATABASE_NAME --port $MONGOS_PORT --eval "db.results.remove()"  
mongo --host $MONGOS_MAIN_PLATFORM $DATABASE_NAME --port $MONGOS_PORT --eval "db.journals.remove()"      
    # start the test on the main mongos platform (workaround for the concurrent oak repositories init)   
    nohup mvn -f /home/$USER/oak-testing/oak-performance/pom.xml clean test -Dtest=@option.TestName@ -Dmongos.number=@option.MongosNumber@ -Dcluster.node=$CLUSTER_NODE_ID -Doak.type=@option.OakType@ 0<&- &>/dev/null &  
    PID=`echo $!`  
    echo Starting the tests on process=$PID  
    for (( ; ; ))  
    do  
        sleep $PROCESS_TIMEOUT  
        if ps -p $PID > /dev/null  
        then  
           echo "$PID is running"  
        else  
           break  
        fi  
    done    
else   
      # wait for the repository to be initialized from the main mongos platform   
      sleep 60       
    nohup mvn -f /home/$USER/oak-testing/oak-performance/pom.xml clean test -Dtest=@option.TestName@ -Dmongos.number=@option.MongosNumber@ -Dcluster.node=$CLUSTER_NODE_ID -Doak.type=@option.OakType@ 0<&- &>/dev/null &  
    PID=`echo $!`  
    echo Starting the tests on process=$PID  
    for (( ; ; ))  
    do  
        sleep $PROCESS_TIMEOUT  
        if ps -p $PID > /dev/null  
        then  
           echo "$PID is running"  
        else  
           break  
        fi  
    done    
fi
