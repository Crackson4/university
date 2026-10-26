package src;

import contracts.*;

/**
 * Train
 */
public class Train extends Vehicle {

    public Train(String id) {
        super(id);
    }

    @Override
    public void advance() {
        if (this.status == VehicleStatus.IN_SERVICE) {
            this.status = VehicleStatus.AT_STOP;
            this.position += 4;
        } else if (this.status == VehicleStatus.AT_STOP)
            this.status = VehicleStatus.IN_SERVICE;
    }

}
