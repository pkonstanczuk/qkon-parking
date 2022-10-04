package pl.qkon.qparking.router;


import com.amazonaws.services.lambda.runtime.LambdaLogger;
import lombok.AccessLevel;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.util.Objects;


@NoArgsConstructor(access = AccessLevel.PRIVATE)
public class Logger {

    @Setter
    private static LambdaLogger lambdaLogger = null;

    public static void info(String entry) {
        if (Objects.nonNull(lambdaLogger)) {
            lambdaLogger.log(entry);
        } else {
            System.out.println(entry);
        }
    }
}
