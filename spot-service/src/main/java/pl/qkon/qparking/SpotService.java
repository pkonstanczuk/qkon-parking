package pl.qkon.qparking;

import java.util.Optional;

public class SpotService {
    public static void main(String[] args) {
        String path = Optional.ofNullable(System.getenv("PATH2")).orElse("N/A");
        System.out.println(path);
    }
}
