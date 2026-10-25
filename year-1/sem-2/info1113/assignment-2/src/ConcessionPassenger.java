package src;

import contracts.*;
import java.util.*;

/**
 * ConcessionPassenger
 */
public class ConcessionPassenger extends Passenger {
    private String concessionType;
    private int age;

    public ConcessionPassenger(String name, String concessionType, int age) {
        super(name);

        if (age < 0)
            throw new IllegalArgumentException("Age cannot be negative");

        Set<String> types = new HashSet<String>(Arrays.asList(
                "A", "D", "V", "AD", "AV", "DV", "ADV"));

        if (concessionType == null || !types.contains(concessionType))
            throw new IllegalArgumentException("Invalid concession type");

        this.concessionType = concessionType;
        this.age = age;
    }

    @Override
    public long applyDiscount(long fareCents) {
        if (isEligible())
            fareCents /= 2;

        return fareCents;
    }

    public String getConcessionType() {
        return concessionType;
    }

    public int getAge() {
        return age;
    }

    public boolean isEligible() {
        if (this.concessionType.charAt(0) != 'A')
            return true;

        return this.age >= 65;
    }
}
