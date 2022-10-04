package pl.qkon.qparking.router;

import com.amazonaws.services.lambda.runtime.events.APIGatewayProxyRequestEvent;
import com.amazonaws.services.lambda.runtime.events.APIGatewayProxyResponseEvent;
import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import pl.qkon.qparking.api.SpotsApi;
import pl.qkon.qparking.model.Spot;
import pl.qkon.qparking.validation.Validator;

@RequiredArgsConstructor
public class ApiRouter {

    private static final Gson GSON = new GsonBuilder().setPrettyPrinting().create();

    private final SpotsApi spotsApi;

    public APIGatewayProxyResponseEvent handle(APIGatewayProxyRequestEvent event) {
        switch (Route.map(event)) {
            case CREATE_SPOT:
                return mapResponse(spotsApi._createSpot(parse(event.getBody(), Spot.class)));
            case GET_SPOTS:
                return mapResponse(ResponseEntity.ok().build());
            default:
                throw new IllegalStateException("Not supported endpoint");
        }
    }

    private static <T> APIGatewayProxyResponseEvent mapResponse(ResponseEntity<T> response) {
        return new APIGatewayProxyResponseEvent()
                .withBody(response.hasBody() ? GSON.toJson(response.getBody()) : null)
                .withStatusCode(response.getStatusCodeValue());

    }

    private static <T> T parse(String body, Class<T> type) {
        T entry = GSON.fromJson(body, type);
        Validator.validate(entry);
        return entry;
    }
}
