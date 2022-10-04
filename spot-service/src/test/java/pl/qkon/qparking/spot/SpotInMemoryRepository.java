package pl.qkon.qparking.spot;

import lombok.AccessLevel;
import lombok.RequiredArgsConstructor;
import pl.qkon.qparking.model.City;
import pl.qkon.qparking.model.Spot;

import java.util.*;


@RequiredArgsConstructor(access = AccessLevel.PUBLIC)
class SpotInMemoryRepository implements SpotRepository {

    private final Map<String, Spot> data = new HashMap<>();


    @Override
    public Optional<Spot> post(City city, Spot dto) {
        Spot spot = dto.token(UUID.randomUUID().toString());
        data.put(spot.getToken(), spot);
        return Optional.of(spot);
    }

    @Override
    public Optional<Spot> update(City city, String token, Spot dto) {
        if (data.containsKey(token)) {
            Spot spot = dto.token(token);
            data.put(spot.getToken(), spot);
            return Optional.of(spot);
        }
        return Optional.empty();
    }

    @Override
    public Optional<Spot> get(City city, String token) {
        return Optional.ofNullable(data.get(token));
    }

    @Override
    public List<Spot> getAll(City city) {
        return new ArrayList<>(data.values());
    }

    @Override
    public boolean delete(City city, String token) {
        return Optional.ofNullable(data.remove(token)).isPresent();
    }
}
