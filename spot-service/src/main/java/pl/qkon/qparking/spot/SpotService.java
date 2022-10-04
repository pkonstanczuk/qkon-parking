package pl.qkon.qparking.spot;

import lombok.AccessLevel;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import pl.qkon.qparking.api.SpotsApi;
import pl.qkon.qparking.model.Spot;
import pl.qkon.qparking.validation.Validator;

@RequiredArgsConstructor(access = AccessLevel.PACKAGE)
public class SpotService implements SpotsApi {

    @Override
    public ResponseEntity<Spot> _createSpot(Spot spot) {
        Validator.validate(spot);
        return null;
    }

    public static SpotsApi create() {
        return new SpotService();
    }

}
