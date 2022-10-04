package pl.qkon.qparking.spot;

import lombok.AccessLevel;
import lombok.NonNull;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import pl.qkon.qparking.api.SpotsApi;
import pl.qkon.qparking.model.City;
import pl.qkon.qparking.model.Spot;
import pl.qkon.qparking.validation.Validator;

import java.util.List;

import static pl.qkon.qparking.spot.SpotRepository.DEFAULT_CITY;

@RequiredArgsConstructor(access = AccessLevel.PACKAGE)
class SpotService implements SpotsApi {


    @NonNull
    private final SpotRepository spotRepository;

    @Override
    public ResponseEntity<Spot> _createSpot(Spot spot) {
        Validator.validate(spot);
        return ResponseEntity.of(spotRepository.post(DEFAULT_CITY, spot));
    }

    @Override
    public ResponseEntity<Void> _deleteSpot(String spotToken) {
        return spotRepository.delete(DEFAULT_CITY, spotToken) ? ResponseEntity.noContent().build() : ResponseEntity.notFound().build();
    }

    @Override
    public ResponseEntity<Spot> _getSpot(String spotToken) {
        return spotRepository.get(DEFAULT_CITY, spotToken)
                .map(ResponseEntity::ok)
                .orElseGet(() -> ResponseEntity.notFound().build());
    }

    @Override
    public ResponseEntity<List<Spot>> _getSpots() {
        return ResponseEntity.ok(spotRepository.getAll(DEFAULT_CITY));
    }

    @Override
    public ResponseEntity<Spot> _updateSpot(String spotToken, Spot spot) {
        return spotRepository.update(DEFAULT_CITY, spotToken, spot)
                .map(ResponseEntity::ok)
                .orElseGet(() -> ResponseEntity.notFound().build());
    }

    public static SpotsApi create() {
        return new SpotService(new SpotDynamoRepository());
    }

}
