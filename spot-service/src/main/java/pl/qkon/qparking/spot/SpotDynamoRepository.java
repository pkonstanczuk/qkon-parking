package pl.qkon.qparking.spot;

import com.amazonaws.services.dynamodbv2.AmazonDynamoDBClientBuilder;
import com.amazonaws.services.dynamodbv2.document.*;
import lombok.AccessLevel;
import lombok.NonNull;
import lombok.RequiredArgsConstructor;
import pl.qkon.qparking.model.City;
import pl.qkon.qparking.model.Spot;

import java.util.ArrayList;
import java.util.List;
import java.util.Optional;
import java.util.UUID;


@RequiredArgsConstructor(access = AccessLevel.PACKAGE)
class SpotDynamoRepository implements SpotRepository {


    @NonNull
    private final Table table = new DynamoDB(AmazonDynamoDBClientBuilder
            .standard()
            .build())
            .getTable(
                    Optional.ofNullable(System.getenv("TABLE_NAME"))
                            .orElse("DEC_SPOTS")
            );


    public Optional<Spot> post(City city, Spot dto) {
        dto.token(UUID.randomUUID().toString());
        Item item = Item.fromJSON(Beans.GSON.toJson(dto));
        table.putItem(item);
        return Optional.of(dto);
    }

    @Override
    public Optional<Spot> update(City city, String token, Spot dto) {
        return Optional.empty();
    }

    @Override
    public Optional<Spot> get(City city, String token) {
        Item item = table.getItem(token, token);
        Spot spot = Beans.GSON.fromJson(item.toJSON(), Spot.class);
        return Optional.ofNullable(spot);
    }

    @Override
    public List<Spot> getAll(City city) {
        table.getItemOutcome(getPrimaryKey(city));
        return new ArrayList<>();
    }

    @Override
    public boolean delete(City city, String token) {
        table.deleteItem(getPrimaryKey(city), getRangeKey(token));
        return false;
    }

    private static KeyAttribute getPrimaryKey(City value) {
        return new KeyAttribute(PRIMARY_KEY, value.getValue());
    }

    private static KeyAttribute getRangeKey(String value) {
        return new KeyAttribute(RANGE_KEY, value);
    }
}
