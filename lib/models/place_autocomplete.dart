class PlaceAutocomplete {
  final String description;
  final String placeId;

  PlaceAutocomplete({
    required this.description,
    required this.placeId,
  });

  factory PlaceAutocomplete.fromMap(Map<String, dynamic> map) {
    return PlaceAutocomplete(
      description: map['description'],
      placeId: map['place_id'],
    );
  }
}
