package pl.qkon.qparking.spot;

import pl.qkon.qparking.model.Spot;

public interface SpotRepository {

    Spot post(Spot dto);
}
