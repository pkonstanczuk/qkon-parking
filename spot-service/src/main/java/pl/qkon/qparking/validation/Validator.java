package pl.qkon.qparking.validation;

import com.amazonaws.services.lambda.runtime.events.APIGatewayProxyResponseEvent;
import lombok.AccessLevel;
import lombok.NoArgsConstructor;

import javax.validation.ConstraintViolation;
import javax.validation.Validation;
import java.util.Set;
import java.util.stream.Collectors;

@NoArgsConstructor(access = AccessLevel.PACKAGE)
public class Validator {

    private static final javax.validation.Validator VALIDATOR = Validation.buildDefaultValidatorFactory().getValidator();

    public static <T> void validate(T entry) {
        Set<ConstraintViolation<T>> violations = VALIDATOR.validate(entry);
        if (!violations.isEmpty()) {
            throw new ValidationException(violations.stream().map(ConstraintViolation::getMessage)
                    .collect(Collectors.toSet()));
        }
    }

    public static APIGatewayProxyResponseEvent mapException(ValidationException exception) {
        return new APIGatewayProxyResponseEvent().withStatusCode(404).withBody(exception.violations.toString());
    }
}
