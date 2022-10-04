package pl.qkon.qparking.spot;

import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import pl.qkon.qparking.api.SpotsApi;

public interface Beans {

    Gson GSON = new GsonBuilder().setPrettyPrinting().create();

    static SpotsApi getSpotService() {
        return SpotService.create();
    }
}
