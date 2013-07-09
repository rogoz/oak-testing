package org.apache.jackrabbit.oak.tests.perf;

import java.util.Random;

import javax.jcr.Node;
import javax.jcr.SimpleCredentials;

import org.apache.jackrabbit.mk.testing.OakMongoTestBase;
import org.apache.jackrabbit.oak.plugins.mongomk.MongoMK;
import org.apache.jackrabbit.oak.plugins.mongomk.util.MongoConnection;
import org.apache.jackrabbit.oak.jcr.Jcr;
import org.junit.Before;
import org.junit.Test;

public class REITest extends OakMongoTestBase {

	@Before
	public void beforeTest() throws Exception {

		Random random = new Random();
		MongoMK.Builder mkBuilder = new MongoMK.Builder();
		MongoConnection connection = new MongoConnection(conf.getHost(),
				conf.getMongoPort(), conf.getMongoDatabase());
		mkBuilder.setMongoDB(connection.getDB());
		mkBuilder.setClusterId(random.nextInt(1000));
		// create repository
		repo = new Jcr(mkBuilder.open()).createRepository();
		adminSession = repo.login(new SimpleCredentials("admin", "admin"
				.toCharArray()));
	}

	/**
	 * The total number of products of variants must be multiplied with the oak
	 * instances number.
	 * 
	 * @throws Exception
	 */
	@Test
	public void test125KProductsx375KVariants() throws Exception {
		int count = 0;
		Node root = adminSession.getRootNode();
		dbWriter.initialCommit("syncOAK");
		dbWriter.syncMongos(mongosNumber, "syncOAK");

		Node ni1 = root.addNode("departament" + nodeNamePrefix, "nt:unstructured");
		for (int i2 = 0; i2 < 100; i2++) {
			Node ni2 = ni1
					.addNode("section" + nodeNamePrefix + i2, "nt:folder");
			for (int i3 = 0; i3 < 25; i3++) {
				Node ni3 = ni2.addNode("group" + nodeNamePrefix + i3,
						"nt:folder");
				for (int i4 = 0; i4 < 50; i4++) {
					Node ni4 = ni3.addNode("product" + nodeNamePrefix + i4,
							"nt:folder");
					for (int i5 = 0; i5 < 4; i5++) {
						ni4.addNode("size" + nodeNamePrefix + i5,
								"nt:folder");
					}
				}
			}
			monitor.start();
			adminSession.save();
			monitor.stop();
			dbWriter.insertResult(Integer.toString(count++),
					(float) monitor.getLastValue(), "results");
		}
		String summary = String.format(
				"Max=%s Min=%s Avg=%s Hits=%s FirstAccess=%s LastAccess=%s",
				monitor.getMax(), monitor.getMin(), monitor.getAvg(),
				monitor.getHits(), monitor.getFirstAccess(),
				monitor.getLastAccess());
		dbWriter.insertFinalResult(summary, "summary");
	}
	
	/**
	 * The total number of products of variants must be multiplied with the oak
	 * instances number.
	 * 
	 * @throws Exception
	 */
	@Test
	public void test1MProductsx3MVariants() throws Exception {
		int count = 0;
		Node root = adminSession.getRootNode();
		dbWriter.initialCommit("syncOAK");
		dbWriter.syncMongos(mongosNumber, "syncOAK");

		Node ni1 = root.addNode("departament" + nodeNamePrefix, "nt:unstructured");
		for (int i2 = 0; i2 < 650; i2++) {
			Node ni2 = ni1
					.addNode("section" + nodeNamePrefix + i2, "nt:folder");
			for (int i3 = 0; i3 < 25; i3++) {
				Node ni3 = ni2.addNode("group" + nodeNamePrefix + i3,
						"nt:folder");
				for (int i4 = 0; i4 < 50; i4++) {
					Node ni4 = ni3.addNode("product" + nodeNamePrefix + i4,
							"nt:folder");
					for (int i5 = 0; i5 < 4; i5++) {
						ni4.addNode("size" + nodeNamePrefix + i5,
								"nt:folder");
					}
				}
			}
			monitor.start();
			adminSession.save();
			monitor.stop();
			dbWriter.insertResult(Integer.toString(count++),
					(float) monitor.getLastValue(), "results");
		}
		String summary = String.format(
				"Max=%s Min=%s Avg=%s Hits=%s FirstAccess=%s LastAccess=%s",
				monitor.getMax(), monitor.getMin(), monitor.getAvg(),
				monitor.getHits(), monitor.getFirstAccess(),
				monitor.getLastAccess());
		dbWriter.insertFinalResult(summary, "summary");
	}
}
