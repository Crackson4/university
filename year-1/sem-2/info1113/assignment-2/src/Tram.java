package src;

import contracts.*;

/**
 * Tram
 */
public class Tram extends Vehicle {

    public Tram(String id) {
        super(id);
    }

    @Override
    public void advance() {
        if (this.status == VehicleStatus.IN_SERVICE) {
            this.status = VehicleStatus.APPROACHING;
            this.position += 1;
        } else if (this.status == VehicleStatus.APPROACHING) {
            this.status = VehicleStatus.IN_SERVICE;
            this.position += 2;
        }
    }

}
