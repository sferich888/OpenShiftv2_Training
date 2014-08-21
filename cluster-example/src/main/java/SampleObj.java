package src.main.java;

import java.io.IOException;
import java.io.Serializable;
import org.apache.log4j.Logger;

public class SampleObj implements Serializable {

    public static final Logger LOG = Logger.getLogger(SampleObj.class);

    private String name = "SampleObj";
    private int value = 0; 

    public SampleObj() {
        LOG.info("--Sample Object Created--");
    }

    public void setName(String new_name) {
        this.name = new_name; 
    }
    
    public String getName() {
        LOG.debug("Name: " + this.name);
        return this.name; 
    }
    
    public void setValue(int new_value) {
        this.value = new_value; 
    }

    public void addValue() {
        this.value += 1; 
    }
    
    public void addValue(int additional_value) {
        this.value += additional_value;
    }
    
    public int getValue() {
        LOG.debug("Value: " + this.value);
        return this.value; 
    }
}
