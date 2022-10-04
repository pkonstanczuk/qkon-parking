package pl.qkon.qparking.router;

import com.amazonaws.services.lambda.runtime.events.APIGatewayProxyRequestEvent;
import lombok.AccessLevel;
import lombok.RequiredArgsConstructor;

import java.util.Arrays;

@RequiredArgsConstructor(access = AccessLevel.PRIVATE)
enum Route {
    CREATE_SPOT("POST", Constants.REST_MULTI_PATH),
    DELETE_SPOT("DELETE", Constants.REST_SINGLE_PATH),
    UPDATE_SPOT("PUT", Constants.REST_SINGLE_PATH),
    GET_SPOT("GET", Constants.REST_SINGLE_PATH),
    GET_SPOTS("GET", Constants.REST_MULTI_PATH);

    private final String httpMethod;
    private final String path;


    public static Route map(APIGatewayProxyRequestEvent event) {
        return Arrays.stream(Route.values())
                .filter(entry -> entry.httpMethod.equalsIgnoreCase(event.getHttpMethod()))
                .filter(entry -> entry.path.equalsIgnoreCase(event.getPath()))
                .findAny()
                .orElseThrow();

    }

    private static class Constants {
        public static final String REST_SINGLE_PATH = "/spots/{spotToken}";
        public static final String REST_MULTI_PATH = "/spots";
    }
}
