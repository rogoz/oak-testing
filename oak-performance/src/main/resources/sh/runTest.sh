#!/bin/bash


RUNDECK_HOME=$1
PATH=${PATH}:${RUNDECK_HOME}tools/bin


# use -t for the testName (testClass#testMetod)
TEST_NAME=
OAK_TYPE=

while getopts p:t:m:o: option
do
        case "${option}"
        in
		p) RUNDECK_HOME=${OPTARG};;
                t) TEST_NAME=${OPTARG};;
		m) OAK_TYPE=${OPTARG};;
                o) OUTPUT_DIR=${OPTARG};;
        esac
done

# Clean results, and database
echo "***** Step 1: Clean environemnt start. *****"
run -j x-cleanCollections --follow
echo "***** Step 1: Clean environment completed. *****"

# Start the tests
echo "***** Step 2: Run the test ${TEST_NAME} with oak type ${OAK_TYPE}. *****"
run -j a-startOakTests --follow -- -TEST_NAME ${TEST_NAME} -OAK_TYPE ${OAK_TYPE}
echo "***** Step 2: Test run completed. *****"

# Generate results
echo "***** Step 3: Generate results. *****"
run -j b-generateOakResults --follow 
echo "***** Step 3: Generate results completed. *****"

# Collect results
echo "***** Step 4: Collect results on local. *****"
run -j c-getResultsOnLocal --follow -- -OUTPUT_DIR ${OUTPUT_DIR}
echo "***** Step 4: Collect results on local ended. *****"

