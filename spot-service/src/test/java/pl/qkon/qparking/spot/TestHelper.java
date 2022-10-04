package pl.qkon.qparking.spot;

public interface TestHelper extends Beans {

    static SpotService getTestSpotService() {
        return new SpotService(new SpotInMemoryRepository());
    }
}
