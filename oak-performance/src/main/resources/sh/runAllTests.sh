#/bin/bash

RUNDECK_HOME=$1

# test 1

./runTest.sh -p ${RUNDECK_HOME} -t OAKTest#testFlatStructure -m mongomk -o testFlatStructure

# test 2

./runTest.sh -p ${RUNDECK_HOME} -t OAKTest#testPyramidStructure -m mongomk -o testPyramidStructure

# test 3

./runTest.sh -p ${RUNDECK_HOME} -t OAKTest#testLargePyramidStructure -m mongomk -o testLargePyramidStructure

# test 4

./runTest.sh -p ${RUNDECK_HOME} -t MKTest#testLargePyramidStructure -m mongomk -o MktestLargePyramidStructure

# test 5

./runTest.sh -p ${RUNDECK_HOME} -t MKTest#testFlatStructure -m mongomk -o MktestFlatStructure

#test 6

./runTest.sh -p ${RUNDECK_HOME} -t MKTest#testLargeFlatStructure -m mongomk -o MktestLargeFlatStructure

#test 7

./runTest.sh -p ${RUNDECK_HOME} -t MKTest#testLargeFlatStructure -m mongomk -o MktestLargeFlatStructure

#test 8

./runTest.sh -p ${RUNDECK_HOME} -t MKTest#testPyramidStructure -m mongomk -o MktestPyramidStructure

