package pl.qkon.qparking.router;

import com.amazonaws.services.lambda.runtime.events.APIGatewayProxyRequestEvent;
import com.amazonaws.services.lambda.runtime.events.APIGatewayProxyResponseEvent;
import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import org.junit.jupiter.api.Assertions;
import org.junit.jupiter.api.Test;
import pl.qkon.qparking.model.City;
import pl.qkon.qparking.model.Location;
import pl.qkon.qparking.model.Spot;
import pl.qkon.qparking.spot.TestHelper;

import java.math.BigDecimal;
import java.util.Arrays;
import java.util.Collections;

import static pl.qkon.qparking.spot.Beans.GSON;

class SpotApiRouterTest {

    @Test
    void crudTest() {
        var router = new ApiRouter(TestHelper.getTestSpotService());

        Spot spot = new Spot()
                .name("name")
                .city(City.WARSAW)
                .location(new Location().latitude(BigDecimal.ONE).longitude(BigDecimal.TEN));


        APIGatewayProxyResponseEvent result = router.handle(new APIGatewayProxyRequestEvent()
                .withHttpMethod("POST")
                .withBody(GSON.toJson(spot))
                .withPath("/spots"));

        Assertions.assertEquals(200, result.getStatusCode());
        Spot fetched = GSON.fromJson(result.getBody(), Spot.class);
        Assertions.assertNotNull(fetched.getToken());

        result = router.handle(new APIGatewayProxyRequestEvent()
                .withHttpMethod("GET")
                .withPathParameters(Collections.singletonMap("spotToken", fetched.getToken()))
                .withPath("/spots/{spotToken}"));
        Assertions.assertEquals(200, result.getStatusCode());
        Assertions.assertEquals(GSON.toJson(fetched), result.getBody());

        result = router.handle(new APIGatewayProxyRequestEvent()
                .withHttpMethod("GET")
                .withPath("/spots"));
        var fetchedList = Arrays.asList(GSON.fromJson(result.getBody(), Spot[].class));
        Assertions.assertEquals(200, result.getStatusCode());
        Assertions.assertEquals(1, fetchedList.size());

        result = router.handle(new APIGatewayProxyRequestEvent()
                .withHttpMethod("DELETE")
                .withPathParameters(Collections.singletonMap("spotToken", fetched.getToken()))
                .withPath("/spots/{spotToken}"));
        Assertions.assertEquals(204, result.getStatusCode());

        result = router.handle(new APIGatewayProxyRequestEvent()
                .withHttpMethod("GET")
                .withPathParameters(Collections.singletonMap("spotToken", fetched.getToken()))
                .withPath("/spots/{spotToken}"));
        Assertions.assertEquals(404, result.getStatusCode());
        Assertions.assertNull(result.getBody());


    }

}