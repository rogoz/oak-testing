#/bin/bash

# test 1

./runTest.sh -t OAKTest#testFlatStructure -m mongomk -o testFlatStructure

# test 2

./runTest.sh -t OAKTest#testPyramidStructure -m mongomk -o testPyramidStructure

# test 3

./runTest.sh -t OAKTest#testLargePyramidStructure -m mongomk -o testLargePyramidStructure

# test 4

./runTest.sh -t MKTest#testLargePyramidStructure -m mongomk -o MktestLargePyramidStructure

# test 5

./runTest.sh -t MKTest#testFlatStructure -m mongomk -o MktestFlatStructure

#test 6

./runTest.sh -t MKTest#testLargeFlatStructure -m mongomk -o MktestLargeFlatStructure

#test 7

./runTest.sh -t MKTest#testLargeFlatStructure -m mongomk -o MktestLargeFlatStructure

#test 8

./runTest.sh -t MKTest#testPyramidStructure -m mongomk -o MktestPyramidStructure

