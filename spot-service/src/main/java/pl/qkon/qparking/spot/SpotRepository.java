package pl.qkon.qparking.spot;

import pl.qkon.qparking.model.City;
import pl.qkon.qparking.model.Spot;

import java.util.List;
import java.util.Optional;

interface SpotRepository {

    String PRIMARY_KEY = "city";
    String RANGE_KEY = "spotToken";
    City DEFAULT_CITY = City.WARSAW;

    Optional<Spot> post(City city, Spot dto);

    Optional<Spot> update(City city, String token, Spot dto);

    Optional<Spot> get(City city, String token);

    List<Spot> getAll(City city);

    boolean delete(City city, String token);
}
