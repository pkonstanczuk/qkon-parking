package pl.qkon.qparking;

import com.amazonaws.services.lambda.runtime.Context;
import com.amazonaws.services.lambda.runtime.LambdaLogger;
import org.junit.jupiter.api.Assertions;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.Mockito;
import org.mockito.junit.jupiter.MockitoExtension;

import java.util.HashMap;

import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class LambdaRunnerTest {

    @Test
    void handleRequest(@Mock Context context) {
        when(context.getLogger()).thenReturn(Mockito.mock(LambdaLogger.class));

        var lr = new LambdaRunner();
        String result = lr.handleRequest(new HashMap<>(), context);
        Assertions.assertEquals("200 OK", result);
    }
}