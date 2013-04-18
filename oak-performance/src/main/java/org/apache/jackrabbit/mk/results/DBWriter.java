package org.apache.jackrabbit.mk.results;

import com.mongodb.BasicDBObject;
import com.mongodb.DB;

public class DBWriter {

    String clusterNodeId;
    DB database;

    public DBWriter(String clusterNodeId, DB database) {
        this.clusterNodeId = clusterNodeId;
        this.database = database;
    }
    
    public String initialCommit(String collectionName){
        BasicDBObject document = new BasicDBObject();
        document.put(clusterNodeId, "1");
        database.getCollection(collectionName).insert(document);
        return clusterNodeId;
    }
    
    public void syncMongos(int mongosNumber, String collectionName) throws InterruptedException{
        while (database.getCollection(collectionName).count() != mongosNumber) {
            Thread.sleep(1000);
        }
    }
    
    public void insertResult(String commitNumber,float value, String collectionName){
        BasicDBObject doc = new BasicDBObject("clusterNodeId", clusterNodeId).append("commitNumber", commitNumber).
                append("v", value);
        database.getCollection(collectionName).insert(doc);
    }
    
    public void insertFinalResult(String value, String collectionName){
        BasicDBObject doc = new BasicDBObject("clusterNodeId", clusterNodeId).append("value", value);
        database.getCollection(collectionName).insert(doc);
    }
}
