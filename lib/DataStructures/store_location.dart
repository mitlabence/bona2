import 'package:bona2/DataStructures/receipt.dart';

class StoreLocation {
  String name; // The name of the store
  String country;
  String city;
  String address; // most commonly, the street and number
  String? postalCode;
  String? placeId;

  StoreLocation(
      {required this.name,
      required this.country,
      required this.city,
      required this.address,
      this.postalCode,
      this.placeId});

  StoreLocation.empty()
      : country = "",
        city = "",
        address = "",
        name = "",
        postalCode = "",
        placeId = "";

  factory StoreLocation.fromGooglePlaceAutocomplete(
      Map<String, dynamic> prediction) {
    // Entry should be the first {} block of the "predictions" list in the
    // Google Maps Autocomplete API response
    List<dynamic> terms = prediction["terms"];
    // get place ID if exists
    String? placeId =
        prediction.containsKey("place_id") ? prediction["place_id"] : null;
    // Assume format is "name, street, city, country
    String name = terms.first["value"];
    String address = terms[1]["value"];
    String city = terms[2]["value"];
    // postal code, county, other data might be between city and country, but
    // should not be the case...
    String country = terms.last["value"];
    return StoreLocation(
        name: name,
        country: country,
        city: city,
        address: address,
        postalCode: null,
        placeId: placeId);
  }

  StoreLocation.fromReceipt(Receipt receipt)
      : name = receipt.shopName,
        country = receipt.country,
        city = receipt.city,
        address = receipt.address,
        postalCode = receipt.postalCode,
        placeId = receipt.placeId;

  @override
  String toString() {
    return "name: $name\ncountry: $country\ncity: $city\naddress: $address\npostalCode: $postalCode\nplaceId: $placeId\n";
  }
}
