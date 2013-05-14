package org.apache.jackrabbit.mk.testing;

import org.apache.jackrabbit.mk.api.MicroKernel;
import com.mongodb.BasicDBObject;
import com.mongodb.DBAddress;
import com.mongodb.Mongo;

import org.apache.jackrabbit.mongomk.MongoMK;
import org.apache.jackrabbit.mongomk.util.MongoConnection;

public class TenantCreator implements Runnable {

	int tenantsNumber;
	int port;
	String dbPrefixName;
	String host = "localhost";

	public TenantCreator(String dbPrefixName, int port, int tenantsNumber) {
		this.dbPrefixName = dbPrefixName;
		this.tenantsNumber = tenantsNumber;
		this.port = port;
	}

	
	public void run() {

		String databaseName;
		MongoMK.Builder mkBuilder;
		MongoConnection connection;
		MicroKernel mk;
		String initialCommitDiff = "+ \"NODE\": { \"propertyKey\": \"propertyValue\"}";

		for (int i = 1; i <= tenantsNumber; i++) {
			databaseName = dbPrefixName + i;
			try {
				connection = new MongoConnection(host, port, databaseName);
				mkBuilder = new MongoMK.Builder();
				mkBuilder.setMongoDB(connection.getDB());
				mk = mkBuilder.open();
				//enable sharding
				Mongo mongo = new Mongo("localhost",port);
				mongo.getDB("admin").command(new BasicDBObject("enablesharding", databaseName));
				mongo.close();
				// initial commit
				mk.commit("/", initialCommitDiff, null, "Initial commit");
			} catch (Exception e) {
				e.printStackTrace();
			}
		}

	}
}