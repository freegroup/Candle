import 'package:candle/models/location_address.dart';
import 'package:candle/services/geocoding.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class OSMGeocodingService implements GeocodingService {
  @override
  Future<LocationAddress?> getGeolocationAddress({required double lat, required double lon}) async {
    try {
      String url = 'https://nominatim.openstreetmap.org/reverse?format=json&lat=$lat&lon=$lon';
      var response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        Map<String, dynamic> addressInfo = json.decode(response.body)['address'] ?? {};

        // Use 'road' if available and not empty, otherwise fallback to 'city_block' if available
        String street = addressInfo['road'] ?? '';
        if (street.isEmpty && addressInfo.containsKey('city_block')) {
          street = addressInfo['city_block'];
        }

        return LocationAddress(
          street: street,
          number: addressInfo['house_number'] ?? '',
          zip: addressInfo['postcode'] ?? '',
          city: addressInfo['city'] ??
              addressInfo['town'] ??
              addressInfo['village'] ??
              addressInfo['municipality'] ??
              addressInfo['suburb'] ??
              '',
          country: addressInfo['country'] ?? '',
        );
      }
    } on Exception catch (error) {
      print(error);
    }
    return null;
  }
}
