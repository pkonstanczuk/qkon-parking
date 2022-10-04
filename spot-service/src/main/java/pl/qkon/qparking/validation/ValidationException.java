package pl.qkon.qparking.validation;


import lombok.AccessLevel;
import lombok.RequiredArgsConstructor;

import java.util.Set;

@RequiredArgsConstructor(access = AccessLevel.PACKAGE)
public class ValidationException extends RuntimeException {

    public final Set<String> violations;

}
