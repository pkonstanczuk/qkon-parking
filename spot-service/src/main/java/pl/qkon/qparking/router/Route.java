package pl.qkon.qparking.router;

import com.amazonaws.services.lambda.runtime.events.APIGatewayProxyRequestEvent;
import lombok.AccessLevel;
import lombok.RequiredArgsConstructor;

import java.util.Arrays;

@RequiredArgsConstructor(access = AccessLevel.PRIVATE)
enum Route {
    CREATE_SPOT("POST", "/spots"),
    GET_SPOTS("GET", "/spots");

    private final String httpMethod;
    private final String path;


    public static Route map(APIGatewayProxyRequestEvent event) {
        return Arrays.stream(Route.values())
                .filter(entry -> entry.httpMethod.equalsIgnoreCase(event.getHttpMethod()))
                .filter(entry -> entry.path.equalsIgnoreCase(event.getPath()))
                .findAny()
                .orElseThrow();

    }
}
