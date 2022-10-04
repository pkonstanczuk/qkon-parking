package pl.qkon.qparking.validation;

import org.junit.jupiter.api.Assertions;
import org.junit.jupiter.api.Test;
import pl.qkon.qparking.model.Spot;

import static org.junit.jupiter.api.Assertions.*;

class ValidatorTest {

    @Test
    void beanValidation() {
        var spot = new Spot().token("");

        ValidationException thrown = assertThrows(
                ValidationException.class,
                () -> Validator.validate(spot)
        );
        Assertions.assertEquals(2, thrown.violations.size());
    }

}