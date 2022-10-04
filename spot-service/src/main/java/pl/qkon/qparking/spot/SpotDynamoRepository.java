package pl.qkon.qparking.spot;

import lombok.AccessLevel;
import lombok.RequiredArgsConstructor;
import pl.qkon.qparking.model.Spot;


@RequiredArgsConstructor(access = AccessLevel.PACKAGE)
class SpotDynamoRepository implements SpotRepository {


    public Spot post(Spot dto) {
        return null;
    }
}
