package pl.qkon.qparking;

import com.amazonaws.services.lambda.runtime.Context;
import com.amazonaws.services.lambda.runtime.LambdaLogger;
import com.amazonaws.services.lambda.runtime.events.APIGatewayProxyRequestEvent;
import com.amazonaws.services.lambda.runtime.events.APIGatewayProxyResponseEvent;
import org.junit.jupiter.api.Assertions;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.Mockito;
import org.mockito.junit.jupiter.MockitoExtension;
import pl.qkon.qparking.model.Spot;

import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class LambdaRunnerTest {
    @Test
    void handleRequest(@Mock Context context) {
        when(context.getLogger()).thenReturn(Mockito.mock(LambdaLogger.class));

        var lr = new LambdaRunner();
        APIGatewayProxyResponseEvent result = lr.handleRequest(new APIGatewayProxyRequestEvent(), context);
        Assertions.assertEquals(200, result.getStatusCode());
    }

    @Test
    void beanValidation() {
        var spot = new Spot().token("");
        Assertions.assertEquals(2, SpotContext.VALIDATOR.validate(spot).size());
    }
}