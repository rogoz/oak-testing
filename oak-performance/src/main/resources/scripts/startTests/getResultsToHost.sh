#!/bin/bash

RESULT_HTML=results.html
SUMMARY=resultsStats.json
DBSUMMARY=resultsDBStats.json
MK_LOG=.mk.log
MONGOS_MAIN_PLATFORM=`xmllint --xpath 'string(/project/node[1]/@hostname)' mongos.xml`
OUTPUT_DIR=$1

# get results

mkdir -p $OUTPUT_DIR
scp -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no ${USER}@${MONGOS_MAIN_PLATFORM}:/home/${USER}/${RESULT_HTML} ${OUTPUT_DIR}/${RESULT_HTML}
scp -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no ${USER}@${MONGOS_MAIN_PLATFORM}:/home/${USER}/${DBSUMMARY} ${OUTPUT_DIR}/${DBSUMMARY}
scp -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no ${USER}@${MONGOS_MAIN_PLATFORM}:/home/${USER}/${SUMMARY} ${OUTPUT_DIR}/${SUMMARY}

# get test logs
TEMP=`xmllint --xpath '/project/node/@hostname' mongos.xml|sed -e "s/ hostname=/ /g"| sed -e "s/\"/'/g"`
declare -a mongos=($TEMP)

for mongosInstance in "${mongos[@]}" 
do
  mongosInstance_trim=`echo ${mongosInstance}|tr -d ''\'''` 
  scp -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no ${USER}@${mongosInstance_trim}:/home/${USER}/oak-testing/oak-performance/target/mk.log ${OUTPUT_DIR}/${mongosInstance_trim}${MK_LOG}
  sleep 2 
done 



