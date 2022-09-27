package pl.qkon.qparking;

import lombok.AccessLevel;
import lombok.NoArgsConstructor;

import javax.validation.Validation;
import javax.validation.Validator;

@NoArgsConstructor(access = AccessLevel.PRIVATE)
public class SpotContext {
    public static final Validator VALIDATOR = Validation.buildDefaultValidatorFactory().getValidator();
}
