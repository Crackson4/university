package src;

import contracts.*;

/**
 * NormalFare
 */
public class NormalFare implements FarePolicy {

    public NormalFare() {
    }

    public long dayFare(long baseCents, int earlierTripsToday) {
        return baseCents;
    }

}
