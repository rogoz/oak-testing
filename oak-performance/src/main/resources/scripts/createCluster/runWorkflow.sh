#!/bin/bash

RUNDECK_HOME=/home/tudor/Tools/rundeck/
PATH=${PATH}:${RUNDECK_HOME}tools/bin
SHARDS_NUMBER=3
MONGOS_NUMBER=3
HDD_SIZE=25
PROVISIONR_PATH=/home/tudor/repos/incubator-provisionr/karaf/assembly/target/org.apache.provisionr-0.4.0-incubating-SNAPSHOT/bin/
TEST_NAME="OAKTest#testFlatStructure"

# Create shards
echo "***** Step 1: Creating cluster's shards. *****"
echo "Number of shards ${SHARDS_NUMBER}.ETA 10 minutes."
run -i 7 --follow -- -SHARDS_NUMBER ${SHARDS_NUMBER} -HDD_SIZE ${HDD_SIZE} -PROVISIONR_PATH ${PROVISIONR_PATH}
echo "***** Step 1: Completed. *****"

# Configure shards

echo "***** Step 2: Configure cluster's shards. *****"
run -i 1 --follow
echo "***** Step 2: Completed. *****"

# Create mongos
echo "***** Step 3: Create mongos platforms. *****"
run -i 3 --follow -- -MONGOS_NUMBER ${MONGOS_NUMBER} -PROVISIONR_PATH ${PROVISIONR_PATH}
echo "***** Step 3: Completed. *****"

#Configure mongos
echo "***** Step 4: Configure mongos platforms. *****"
run -i 6 --follow
echo "***** Step 4: Completed. *****"

#Start test
echo "***** Step 5: Start tests. *****"
run -i 9 --follow -- -TEST_NAME ${TEST_NAME}
echo "***** Step 5: Completed. *****"


#Collect results
echo "***** Step 6: Collect results. *****"
run -i 10 --follow
echo "***** Step 6: Completed. *****"
