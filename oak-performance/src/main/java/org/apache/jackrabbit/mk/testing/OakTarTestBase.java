package org.apache.jackrabbit.mk.testing;
import java.io.InputStream;
import java.util.Properties;
import javax.jcr.Repository;
import javax.jcr.Session;
import org.junit.Before;
import com.jamonapi.Monitor;
import com.jamonapi.MonitorFactory;
import org.apache.jackrabbit.mk.util.Configuration;



public class OakTarTestBase {

    protected Repository repo;
    protected Session adminSession;
    protected Monitor monitor;
    protected String nodeNamePrefix;
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
        oakType = System.getProperty("oak.type", "mongomk");
        monitor = MonitorFactory.getTimeMonitor("monitor"
                + Thread.currentThread().getId());
        monitor.reset();        
    }
}
