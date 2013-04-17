package org.apache.jackrabbit.mk.testing;
import java.io.InputStream;
import java.util.Properties;
import javax.jcr.Repository;
import javax.jcr.Session;
import org.apache.jackrabbit.mk.results.DBWriter;
import org.apache.jackrabbit.mongomk.util.MongoConnection;
import org.junit.Before;
import com.jamonapi.Monitor;
import com.jamonapi.MonitorFactory;
import org.apache.jackrabbit.mk.util.Configuration;



public class OakMongoTestBase {

    protected Repository repo;
    protected Session adminSession;
    protected Monitor monitor;
    protected String nodeNamePrefix;
    protected DBWriter dbWriter;
    protected String clusterNodeId;
    protected MongoConnection mongoConnection;
    protected int mongosNumber;
    protected Configuration conf;
    protected String oakType;
    @Before
    public void beforeBaseClass() throws Exception {

        // read the connection properties
        InputStream is = OakMongoTestBase.class
                .getResourceAsStream("/config.cfg");
        Properties properties = new Properties();
        properties.load(is);
        is.close();
        conf = new Configuration(properties);
        mongosNumber = Integer.parseInt(System
                .getProperty("mongos.number", "1"));
        clusterNodeId = System.getProperty("cluster.node", "clusterDefaultId");
        oakType = System.getProperty("oak.type", "mongomk");
        mongoConnection = new MongoConnection(conf.getHost(),
                conf.getMongoPort(), conf.getMongoDatabase());
        dbWriter = new DBWriter(clusterNodeId, mongoConnection.getDB());
        monitor = MonitorFactory.getTimeMonitor("monitor"
                + Thread.currentThread().getId());
        monitor.reset();
        nodeNamePrefix = "S" + clusterNodeId + "S";
    }
}
