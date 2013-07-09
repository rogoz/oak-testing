package org.apache.jackrabbit.mk.testing;
import java.io.InputStream;
import java.util.Properties;
import org.apache.jackrabbit.mk.api.MicroKernel;
import org.apache.jackrabbit.mk.results.DBWriter;
import org.apache.jackrabbit.mk.util.Configuration;
import org.apache.jackrabbit.oak.plugins.mongomk.util.MongoConnection;
import org.junit.Before;

import com.jamonapi.Monitor;
import com.jamonapi.MonitorFactory;

public class MongoMkTestBase {

    protected MicroKernel mk;
    protected MongoConnection mongoConnection;
    protected Configuration conf;
    protected int mongosNumber;
    protected String clusterNodeId;
    protected DBWriter dbWriter;
    protected Monitor monitor;
    protected String nodeNamePrefix;
    
    @Before
    public void beforeTestBase() throws Exception {

        InputStream is = MongoMkTestBase.class
                .getResourceAsStream("/config.cfg");
        Properties properties = new Properties();
        properties.load(is);
        is.close();
        conf = new Configuration(properties);
        mongosNumber = Integer.parseInt(System
                .getProperty("mongos.number", "1"));
        clusterNodeId = System.getProperty("cluster.node", "clusterDefaultId");
        mongoConnection = new MongoConnection(conf.getHost(),
                conf.getMongoPort(), conf.getMongoDatabase());
        dbWriter = new DBWriter(clusterNodeId, mongoConnection.getDB());
        monitor = MonitorFactory.getTimeMonitor("monitor"
                + Thread.currentThread().getId());
        monitor.reset();
        nodeNamePrefix = "S" + clusterNodeId + "S";
    }
}
