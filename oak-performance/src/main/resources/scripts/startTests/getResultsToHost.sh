#!/bin/bash

RESULT_HTML=results.html
SUMMARY=resultsStats.json
DBSUMMARY=resultsDBStats.json
MONGOS_MAIN_PLATFORM=`xmllint --xpath 'string(/project/node[1]/@hostname)' mongos.xml`
OUTPUT_DIR=$1

mkdir -p $OUTPUT_DIR
scp ${USER}@${MONGOS_MAIN_PLATFORM}:/home/${USER}/${RESULT_HTML} ${OUTPUT_DIR}/${RESULT_HTML}
scp ${USER}@${MONGOS_MAIN_PLATFORM}:/home/${USER}/${DBSUMMARY} ${OUTPUT_DIR}/${DBSUMMARY}
scp ${USER}@${MONGOS_MAIN_PLATFORM}:/home/${USER}/${SUMMARY} ${OUTPUT_DIR}/${SUMMARY}

