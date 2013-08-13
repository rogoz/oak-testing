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
CONFIG_PORT=50001     
MONGOS_PORT=27017     
MONGOD_PORT=27017
CURRENT_NODE=$1
TEST_NAME=$2
OAK_TYPE=$3
DATABASE_NAME=Oak     
CLUSTER_NODE_ID=${CURRENT_NODE:0:15}     
PROCESS_TIMEOUT=30     
TEMP=`xmllint --xpath '/project/node/@hostname' mongos.xml|sed -e "s/ hostname=/ /g"| sed -e "s/\"/'/g"` 
declare -a mongos=($TEMP)
MONGOS_NUMBER=${#mongos[@]}
echo "MONGOS_NUMBER="${MONGOS_NUMBER}

# Download and set Java  
wget --no-cookies --no-check-certificate --header "Cookie: gpw_e24=http%3A%2F%2Fwww.oracle.com%2Ftechnetwork%2Fjava%2Fjavase%2Fdownloads%2Fjdk6-downloads-1637591.html;" http://download.oracle.com/otn-pub/java/jdk/6u33-b03/jdk-6u33-linux-x64.bin   
chmod a+x jdk-6u33-linux-x64.bin
yes | ./jdk-6u33-linux-x64.bin
export JAVA_HOME=/home/${USER}/jdk1.6.0_33/
export PATH=${JAVA_HOME}bin:$PATH


# Download and set Maven  
wget http://mirrors.hostingromania.ro/apache.org/maven/maven-3/3.0.5/binaries/apache-maven-3.0.5-bin.tar.gz
mkdir maven
tar -xvf apache-maven-3.0.5-bin.tar.gz --strip 1 --directory maven
export M2=/home/${USER}/maven/bin
export MAVEN_OPTS="-Xmx512m -XX:MaxPermSize=128m"
export PATH=$PATH:$M2

# Clone the jackrabbit repository  
echo Clone oak repository  
git clone https://github.com/apache/jackrabbit-oak.git  

# Clone the test repository  
echo Clone test repository  
git clone https://github.com/rogoz/oak-testing.git  
  
# Build OAK  
mvn -f /home/${USER}/jackrabbit-oak/pom.xml clean install -DskipTests  

if [ "$CURRENT_NODE" == "$MONGOS_MAIN_PLATFORM" ]; then     
    mongo --host localhost $DATABASE_NAME --port $MONGOS_PORT --eval "db.nodes.remove()" 
    mongo --host localhost $DATABASE_NAME --port $MONGOS_PORT --eval "db.segments.remove()"     
    mongo --host localhost $DATABASE_NAME --port $MONGOS_PORT --eval "db.results.remove()"  
    mongo --host localhost $DATABASE_NAME --port $MONGOS_PORT --eval "db.summary.remove()"     
    mongo --host localhost $DATABASE_NAME --port $MONGOS_PORT --eval "db.journals.remove()"      
    # start the test on the main mongos platform (workaround for the concurrent oak repositories init)   
    nohup mvn -f /home/${USER}/oak-testing/oak-performance/pom.xml clean test -Dorg.slf4j.simpleLogger.logFile=Oakmk.log -Dorg.slf4j.simpleLogger.defaultLogLevel=info -Dtest=${TEST_NAME} -Dmongos.number=${MONGOS_NUMBER} -Dcluster.node=${CLUSTER_NODE_ID} -Doak.type=${OAK_TYPE} &
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
      sleep 100
      nohup mvn -f /home/${USER}/oak-testing/oak-performance/pom.xml clean test -Dorg.slf4j.simpleLogger.logFile=Oakmk.log -Dorg.slf4j.simpleLogger.defaultLogLevel=info -Dtest=${TEST_NAME} -Dmongos.number=${MONGOS_NUMBER} -Dcluster.node=${CLUSTER_NODE_ID} -Doak.type=${OAK_TYPE} &
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
