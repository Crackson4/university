package src;

import contracts.*;
import java.util.*;

/**
 * TransitApp
 */
public class TransitApp implements TransitSystem {
    private List<Ticket> tickets = new ArrayList<>();
    private List<Vehicle> vehicles = new ArrayList<>();
    private int counter;
    private long revenue = 0;

    public TransitApp() {
        this.counter = 0;
    }

    public TransitApp(int startTick) {
        if (startTick < 0)
            throw new IllegalArgumentException("Start tick cannot be negative");

        this.counter = startTick;
    }

    public int currentTick() {
        return this.counter;
    }

    public int day() {
        return this.counter / 24;
    }

    public void tick() {
        this.counter++;

        for (Vehicle v : this.vehicles)
            v.advance();
    }

    public void addVehicle(Vehicle vehicle) {
        if (vehicle == null)
            throw new IllegalArgumentException("Vehicle is null");

        this.vehicles.add(vehicle);
    }

    public boolean isHoliday() {
        int day = day() % 365;

        int[] holidays = { 0, 25, 114, 358, 359 };

        for (int x : holidays) {
            if (day == x)
                return true;
        }

        return false;
    }

    public Ticket book(Passenger passenger, Trip trip) {
        if (passenger == null)
            throw new IllegalArgumentException("Passenger is null");

        if (trip == null)
            throw new IllegalArgumentException("Trip is null");

        long base = trip.distance() * 25;
        int earlier = 0;

        for (Ticket ticket : this.tickets) {
            if (ticket.passenger() == passenger && ticket.day() == this.day())
                earlier++;
        }

        FarePolicy policy;

        if (isHoliday())
            policy = new HolidayFare();
        else
            policy = new NormalFare();

        long dayFare = policy.dayFare(base, earlier);

        if (dayFare < 0 || dayFare > base)
            throw new IllegalArgumentException("Day fare is invalid");

        long fare = passenger.applyDiscount(dayFare);

        if (fare < 0 || fare > dayFare)
            throw new IllegalArgumentException("Discounted fare is invalid");

        String ticketId = "T" + (this.tickets.size() + 1);

        Ticket newTicket = new Ticket(ticketId, passenger, trip, day(), isHoliday(), base, dayFare, fare);

        this.tickets.add(newTicket);

        this.revenue += fare;

        return newTicket;
    }

    public List<Ticket> tickets() {
        return new ArrayList<Ticket>(this.tickets);
    }

    public long revenueCents() {
        return this.revenue;
    }
}
