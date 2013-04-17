#!/bin/bash  
 
# Removes everything from the working directory 
# Downloads java and set the java environment variables 
# Downloads maven and set the maven environment variables 
# Clones the rogoz/jackrabbit-oak repository 
# Builds jackrabit oak 
# The step is executed concurrently on all mongos platforms 
 
# Define shards  
MONGOS_MAIN_PLATFORM=localhost  
SHARD1_HOST=ec2-50-112-15-19.us-west-2.compute.amazonaws.com 
SHARD2_HOST=ec2-54-244-69-122.us-west-2.compute.amazonaws.com  
SHARD3_HOST=ec2-50-112-30-14.us-west-2.compute.amazonaws.com  
CONFIG_PORT=20001  
MONGOS_PORT=30000  
MONGOD_PORT=27018  
DATABASE_NAME=mongoTestStorage  
  
  
# Clean the user's home folder  
rm -rf *;  
  
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
