#!/bin/bash

# Collects the results from the $DATABASE_NAME
# Builds the RESULT_HTML chart file

MONGOS_NUMBER=3
DATABASE_NAME=mongoTestStorage
COLLECTION_NAME=results
SUMMARY_CNAME=summary
MONGOS_MAIN_PLATFORM=@option.MONGOS_MAIN_PLATFORM@
MONGOS_PORT=30000
RESULT_HTML=results.html
SUMMARY=resultsStats.json
DBSUMMARY=resultsDBStats.json
CURRENT_NODE=@node.hostname@

TOTAL_SAVES=`mongo --host $MONGOS_MAIN_PLATFORM $DATABASE_NAME --port $MONGOS_PORT --quiet --eval "var result=db.${COLLECTION_NAME}.count();printjson(result)"`
INSTANCE_SAVES=$((TOTAL_SAVES / MONGOS_NUMBER ))
echo INSTANCE_SAVES=$INSTANCE_SAVES

# Create the js script
rm -f $RESULT_HTML
rm -f $SUMMARY
rm -f $DBSUMMARY
rm -rf results*

if [ "$CURRENT_NODE" == "$MONGOS_MAIN_PLATFORM" ]; then
    # Add cols
    echo "<html>
      <head>
        <script type=\"text/javascript\" src=\"https://www.google.com/jsapi\"></script>
        <script type=\"text/javascript\">
          google.load(\"visualization\", \"1\", {packages:[\"corechart\"]});
          google.setOnLoadCallback(drawChart);
          function drawChart() {
          var jsonData = {\"cols\": [
    {\"id\":\"\",\"label\":\"commitNumber\",\"type\":\"string\"}" > $RESULT_HTML

    for (( c=0; c<$MONGOS_NUMBER; c++ ))
    do
        echo ",{\"id\":\"\",\"label\":\"clusterNode${c}\",\"type\":\"number\"}" >> $RESULT_HTML
    done
    echo "],\"rows\": [" >> $RESULT_HTML



    for (( c=0; c<$INSTANCE_SAVES; c++ ))
    do
        VALUE=`mongo --host $MONGOS_MAIN_PLATFORM $DATABASE_NAME --port $MONGOS_PORT --quiet --eval "var result=db.${COLLECTION_NAME}.find({'commitNumber':\"$c\"},{v:1,_id:0}).sort({clusterNodeId:-1}).toArray();printjson(result)"`
        RESULT=$(echo $VALUE | sed -e "s/ / {\"v\":\"$c\"}, /")
        if [ $c -eq 0 ]; then
            RESULT="{\"c\":"${RESULT}"}"
        else
            RESULT=",{\"c\":"${RESULT}"}"
        fi
        echo $RESULT >> $RESULT_HTML   
    done

    # Complete the script

    echo "]};
        var data = new google.visualization.DataTable(jsonData);
        var options = {
              title: 'OAK test results'
            };
         var chart = new google.visualization.LineChart(document.getElementById('chart_div'));
         chart.draw(data, options);
    }
        </script>
      </head>
      <body>
        <div id=\"chart_div\" style=\"width: 1600px; height: 1000px;\"></div>
      </body>
    </html>" >> $RESULT_HTML
    
    # Generate the summary file
    VALUE=`mongo --host $MONGOS_MAIN_PLATFORM $DATABASE_NAME --port $MONGOS_PORT --quiet --eval "var result=db.${SUMMARY_CNAME}.find({},{_id:0}).toArray();printjson(result)"`
    echo $VALUE > $SUMMARY
    VALUE=`mongo --host $MONGOS_MAIN_PLATFORM $DATABASE_NAME --port $MONGOS_PORT --quiet --eval "var result=db.stats();printjson(result)"`
    echo $VALUE > $DBSUMMARY	
fi
