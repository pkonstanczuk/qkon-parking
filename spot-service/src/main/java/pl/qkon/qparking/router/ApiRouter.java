package pl.qkon.qparking.router;

import com.amazonaws.services.lambda.runtime.events.APIGatewayProxyRequestEvent;
import com.amazonaws.services.lambda.runtime.events.APIGatewayProxyResponseEvent;
import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import lombok.NonNull;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import pl.qkon.qparking.api.SpotsApi;
import pl.qkon.qparking.model.Spot;
import pl.qkon.qparking.validation.Validator;

import java.util.Optional;

import static pl.qkon.qparking.spot.Beans.GSON;

@RequiredArgsConstructor
public class ApiRouter {

    @NonNull
    private final SpotsApi spotsApi;

    public APIGatewayProxyResponseEvent handle(APIGatewayProxyRequestEvent event) {
        Optional<Spot> spot = Optional.ofNullable(event.getBody())
                .map(body -> parse(body, Spot.class));
        Optional<String> spotToken = Optional.of(event).map(APIGatewayProxyRequestEvent::getPathParameters).map(params -> params.get("spotToken"));
        switch (Route.map(event)) {
            case CREATE_SPOT:
                return mapResponse(spotsApi._createSpot(spot.orElseThrow()));
            case UPDATE_SPOT:
                return mapResponse(spotsApi._updateSpot(spotToken.orElseThrow(), spot.orElseThrow()));
            case DELETE_SPOT:
                return mapResponse(spotsApi._deleteSpot(spotToken.orElseThrow()));
            case GET_SPOT:
                return mapResponse(spotsApi._getSpot(spotToken.orElseThrow()));
            case GET_SPOTS:
                return mapResponse(spotsApi._getSpots());
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
