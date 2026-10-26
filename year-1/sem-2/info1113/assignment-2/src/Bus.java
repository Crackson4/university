package src;

import contracts.*;

/**
 * Bus
 */
public class Bus extends Vehicle {

    public Bus(String id) {
        super(id);
    }

    @Override
    public void advance() {
        this.position += 1;
    }
}
