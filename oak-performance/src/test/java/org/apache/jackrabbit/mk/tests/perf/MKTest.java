package org.apache.jackrabbit.mk.tests.perf;

import java.util.Random;
import org.apache.jackrabbit.mk.testing.MongoMkTestBase;
import org.apache.jackrabbit.mongomk.util.MongoConnection;
import org.apache.jackrabbit.mongomk.MongoMK;
import org.junit.Before;
import org.junit.Test;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.slf4j.impl.SimpleLogger;

public class MKTest extends MongoMkTestBase {

	String property = "justAnotherProperty";
	String value = "justAnotherPropertyValue";
	String message = "justAnotherCommitMessage";

	@Before
	public void beforeTest() throws Exception {
		Random random = new Random();
		MongoMK.Builder mkBuilder = new MongoMK.Builder();
		MongoConnection connection = new MongoConnection(conf.getHost(),
				conf.getMongoPort(), conf.getMongoDatabase());
		mkBuilder.setMongoDB(connection.getDB());
		mkBuilder.setClusterId(random.nextInt(1000));
		mk = mkBuilder.open();
		//SimpleLogger LOG=(SimpleLogger) LoggerFactory.getLogger(MongoMK.class);
		
		
	}

	@Test
	public void testFlatStructure() throws InterruptedException {

		int nodesNumber = 10000;
		int nodesPerSave = 100;
		int count = 0;
		String diff = "";
		dbWriter.initialCommit("syncOAK");
		dbWriter.syncMongos(mongosNumber, "syncOAK");
		for (int i = 1; i <= nodesNumber; i++) {
			diff = diff + "+ \"" + clusterNodeId + i + "\": { \"" + property
					+ "\": \"" + value + "\"}\n";
			if ((i % nodesPerSave) == 0) {
				monitor.start();
				mk.commit("/", diff.trim(), null, message);
				monitor.stop();
				diff = "";
				dbWriter.insertResult(Integer.toString(count++),
						(float) monitor.getLastValue(), "results");
			}
		}
		String summary = String.format(
				"Max=%s Min=%s Avg=%s Hits=%s FirstAccess=%s LastAccess=%s",
				monitor.getMax(), monitor.getMin(), monitor.getAvg(),
				monitor.getHits(), monitor.getFirstAccess(),
				monitor.getLastAccess());
		dbWriter.insertFinalResult(summary, "summary");

	}

	@Test
	public void testLargeFlatStructure() throws InterruptedException {

		int nodesNumber = 100000;
		int nodesPerSave = 1000;
		int count = 0;
		String diff = "";
		dbWriter.initialCommit("syncOAK");
		dbWriter.syncMongos(mongosNumber, "syncOAK");
		for (int i = 1; i <= nodesNumber; i++) {
			diff = diff + "+ \"" + clusterNodeId + i + "\": { \"" + property
					+ "\": \"" + value + "\"}\n";
			if ((i % nodesPerSave) == 0) {
				monitor.start();
				mk.commit("/", diff.trim(), null, message);
				monitor.stop();
				diff = "";
				dbWriter.insertResult(Integer.toString(count++),
						(float) monitor.getLastValue(), "results");
			}
		}
		String summary = String.format(
				"Max=%s Min=%s Avg=%s Hits=%s FirstAccess=%s LastAccess=%s",
				monitor.getMax(), monitor.getMin(), monitor.getAvg(),
				monitor.getHits(), monitor.getFirstAccess(),
				monitor.getLastAccess());
		dbWriter.insertFinalResult(summary, "summary");
	}

	@Test
	public void testPyramidStructure() throws InterruptedException {

		int count = 0;
		String diff = "";
		dbWriter.initialCommit("syncOAK");
		dbWriter.syncMongos(mongosNumber, "syncOAK");
		for (int k = 0; k < 10; k++) {
			diff = diff + "+ \"" + clusterNodeId + k + "\": { \"" + property
					+ "\": \"" + value + "\"}\n";
			for (int j = 0; j < 10; j++) {
				diff = diff + "+ \"" + clusterNodeId + k + "/" + clusterNodeId
						+ j + "\": { \"" + property + "\": \"" + value
						+ "\"}\n";
				for (int i = 0; i < 1000; i++) {
					diff = diff + "+ \"" + clusterNodeId + k + "/"
							+ clusterNodeId + j + "/" + clusterNodeId + i
							+ "\": { \"" + property + "\": \"" + value
							+ "\"}\n";
				}
				monitor.start();
				mk.commit("/", diff.trim(), null, message);
				monitor.stop();
				diff = "";
				dbWriter.insertResult(Integer.toString(count++),
						(float) monitor.getLastValue(), "results");
			}
		}
		String summary = String.format(
				"Max=%s Min=%s Avg=%s Hits=%s FirstAccess=%s LastAccess=%s",
				monitor.getMax(), monitor.getMin(), monitor.getAvg(),
				monitor.getHits(), monitor.getFirstAccess(),
				monitor.getLastAccess());
		dbWriter.insertFinalResult(summary, "summary");
	}

	@Test
	public void testLargePyramidStructure() throws InterruptedException {

		int count = 0;
		String diff = "";
		dbWriter.initialCommit("syncOAK");
		dbWriter.syncMongos(mongosNumber, "syncOAK");
		for (int k = 0; k < 5; k++) {
			diff = diff + "+ \"" + clusterNodeId + k + "\": { \"" + property
					+ "\": \"" + value + "\"}\n";
			for (int j = 0; j < 10; j++) {
				diff = diff + "+ \"" + clusterNodeId + k + "/" + clusterNodeId
						+ j + "\": { \"" + property + "\": \"" + value
						+ "\"}\n";
				for (int i = 0; i < 10; i++) {
					diff = diff + "+ \"" + clusterNodeId + k + "/"
							+ clusterNodeId + j + "/" + clusterNodeId + i
							+ "\": { \"" + property + "\": \"" + value
							+ "\"}\n";
					for (int l = 0; l < 1000; l++) {
						diff = diff + "+ \"" + clusterNodeId + k + "/"
								+ clusterNodeId + j + "/" + clusterNodeId + i
								+ "/" + clusterNodeId + l + "\": { \""
								+ property + "\": \"" + value + "\"}\n";
					}

				}
				monitor.start();
				mk.commit("/", diff.trim(), null, message);
				monitor.stop();
				diff = "";
				dbWriter.insertResult(Integer.toString(count++),
						(float) monitor.getLastValue(), "results");
			}
		}
		String summary = String.format(
				"Max=%s Min=%s Avg=%s Hits=%s FirstAccess=%s LastAccess=%s",
				monitor.getMax(), monitor.getMin(), monitor.getAvg(),
				monitor.getHits(), monitor.getFirstAccess(),
				monitor.getLastAccess());
		dbWriter.insertFinalResult(summary, "summary");
	}
	
	/**
	 * 10,000,000 nodes/ 10,000 per commit
	 * @throws InterruptedException
	 */
	@Test
	public void testHugePyramidStructure() throws InterruptedException {

		int count = 0;
		String diff = "";
		dbWriter.initialCommit("syncOAK");
		dbWriter.syncMongos(mongosNumber, "syncOAK");
		for (int k = 0; k < 10; k++) {
			diff = diff + "+ \"" + clusterNodeId + k + "\": { \"" + property
					+ "\": \"" + value + "\"}\n";
			for (int j = 0; j < 100; j++) {
				diff = diff + "+ \"" + clusterNodeId + k + "/" + clusterNodeId
						+ j + "\": { \"" + property + "\": \"" + value
						+ "\"}\n";
				for (int i = 0; i < 10; i++) {
					diff = diff + "+ \"" + clusterNodeId + k + "/"
							+ clusterNodeId + j + "/" + clusterNodeId + i
							+ "\": { \"" + property + "\": \"" + value
							+ "\"}\n";
					for (int l = 0; l < 1000; l++) {
						diff = diff + "+ \"" + clusterNodeId + k + "/"
								+ clusterNodeId + j + "/" + clusterNodeId + i
								+ "/" + clusterNodeId + l + "\": { \""
								+ property + "\": \"" + value + "\"}\n";
					}

				}
				monitor.start();
				mk.commit("/", diff.trim(), null, message);
				monitor.stop();
				diff = "";
				dbWriter.insertResult(Integer.toString(count++),
						(float) monitor.getLastValue(), "results");
			}
		}
		String summary = String.format(
				"Max=%s Min=%s Avg=%s Hits=%s FirstAccess=%s LastAccess=%s",
				monitor.getMax(), monitor.getMin(), monitor.getAvg(),
				monitor.getHits(), monitor.getFirstAccess(),
				monitor.getLastAccess());
		dbWriter.insertFinalResult(summary, "summary");
	}
}
