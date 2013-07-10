#!/bin/bash     
    
# Removes the documents from syncOAK, NODES and segments collection    
# Launches the test (@option.TestName@) on each platform    
# The step is executed concurrently on all mongos platforms    
    
export JAVA_HOME=/home/$USER/jdk1.6.0_33/      
export PATH=${JAVA_HOME}bin:$PATH     
export M2=/home/$USER/maven/bin     
export MAVEN_OPTS="-Xmx512m -XX:MaxPermSize=128m"     
export PATH=$PATH:$M2     
     
MONGOS_MAIN_PLATFORM=`xmllint --xpath 'string(/project/node[1]/@hostname)' mongos.xml`    
MONGOS_PORT=27017 
MONGOD_PORT=27017     
CURRENT_NODE=$1
TEST_NAME=$2      
DATABASE_NAME=Oak     
CLUSTER_NODE_ID=${CURRENT_NODE:0:15}     
PROCESS_TIMEOUT=30

# Download the tests
echo Clone test repository 
rm -rf oak-testing/ 
git clone https://github.com/rogoz/oak-testing.git

# number of mongos  
TEMP=`xmllint --xpath '/project/node/@hostname' mongos.xml|sed -e "s/ hostname=/ /g"| sed -e "s/\"/'/g"` 
declare -a mongos=($TEMP)
echo mongos=${mongos[@]}
MONGOS_NUMBER=${#mongos[@]}
echo MONGOS_NUMBER=$MONGOS_NUMBER

   
if [ "$CURRENT_NODE" == "$MONGOS_MAIN_PLATFORM" ]; then     
     
    # start the test on the main mongos platform (workaround for the concurrent oak repositories init)   
    nohup mvn -f /home/$USER/oak-testing/oak-performance/pom.xml clean test -Dorg.slf4j.simpleLogger.logFile=Oakmk.log -Dorg.slf4j.simpleLogger.defaultLogLevel=debug -Dtest=$TEST_NAME -Dmongos.number=$MONGOS_NUMBER -Dcluster.node=$CLUSTER_NODE_ID -Doak.type=segmentmk &
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
      nohup mvn -f /home/$USER/oak-testing/oak-performance/pom.xml clean test -Dorg.slf4j.simpleLogger.logFile=Oakmk.log -Dorg.slf4j.simpleLogger.defaultLogLevel=debug -Dtest=$TEST_NAME -Dmongos.number=$MONGOS_NUMBER -Dcluster.node=$CLUSTER_NODE_ID -Doak.type=segmentmk &
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
