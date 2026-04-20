class MosqueModel {
  final String id;
  final String name;
  final String address;
  final double rating;
  final double distanceMeters;
  final bool isOpen;
  final List<String> amenities;
  final double lat;
  final double lng;
  final String? photoReference;

  const MosqueModel({
    required this.id,
    required this.name,
    required this.address,
    required this.rating,
    required this.distanceMeters,
    required this.isOpen,
    required this.amenities,
    required this.lat,
    required this.lng,
    this.photoReference,
  });

  String get distanceLabel {
    if (distanceMeters < 1000) {
      return '${distanceMeters.toInt()} m';
    }
    return '${(distanceMeters / 1000).toStringAsFixed(1)} km';
  }

  factory MosqueModel.fromJson(
    Map<String, dynamic> json, {
    required double distanceMeters,
  }) {
    final location = json['geometry']['location'] as Map<String, dynamic>;
    final openingHours = json['opening_hours'] as Map<String, dynamic>?;
    final photos = json['photos'] as List<dynamic>?;
    final types = (json['types'] as List<dynamic>? ?? [])
        .map((t) => t.toString())
        .where((t) => _displayableAmenity(t) != null)
        .map((t) => _displayableAmenity(t)!)
        .take(2)
        .toList();

    return MosqueModel(
      id: json['place_id'] as String,
      name: json['name'] as String,
      address: json['vicinity'] as String? ?? '',
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      distanceMeters: distanceMeters,
      isOpen: openingHours?['open_now'] as bool? ?? false,
      amenities: types,
      lat: (location['lat'] as num).toDouble(),
      lng: (location['lng'] as num).toDouble(),
      photoReference:
          photos != null && photos.isNotEmpty
              ? photos.first['photo_reference'] as String?
              : null,
    );
  }

  static String? _displayableAmenity(String type) {
    const map = {
      'parking': 'Parking',
      'wheelchair_accessible': 'Accessible',
      'prayer_room': 'Prayer Room',
      'wudu': 'Wudu',
    };
    return map[type];
  }
}
