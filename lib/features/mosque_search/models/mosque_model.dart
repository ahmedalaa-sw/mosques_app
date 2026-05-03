import 'package:mosques_app/core/constants/app_strings.dart';
import 'package:mosques_app/core/network/endpoint_constants.dart';

class MosqueModel {
  final String id;
  final String name;
  final String address;
  final double distanceMeters;
  final bool? isOpen;
  final String statusLabel;
  final List<String> amenities;
  final double lat;
  final double lng;
  final String? photoReference;

  const MosqueModel({
    required this.id,
    required this.name,
    required this.address,
    required this.distanceMeters,
    required this.isOpen,
    required this.statusLabel,
    required this.amenities,
    required this.lat,
    required this.lng,
    this.photoReference,
  });

  String? get photoUrl => photoReference == null
      ? null
      : EndpointConstants.placePhotoUrl(photoReference!);

  String get distanceLabel {
    if (distanceMeters < 1000) {
      return '${distanceMeters.toInt()} m';
    }
    return '${(distanceMeters / 1000).toStringAsFixed(1)} km';
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'address': address,
        'distanceMeters': distanceMeters,
        'isOpen': isOpen,
        'statusLabel': statusLabel,
        'amenities': amenities,
        'lat': lat,
        'lng': lng,
        'photoReference': photoReference,
      };

  factory MosqueModel.fromCache(Map<String, dynamic> json) {
    final isOpen = json['isOpen'] as bool?;
    final cachedStatusLabel = json['statusLabel'] as String?;

    return MosqueModel(
      id: json['id'] as String,
      name: json['name'] as String,
      address: json['address'] as String,
      distanceMeters: (json['distanceMeters'] as num).toDouble(),
      isOpen: isOpen,
      statusLabel: _cachedStatusLabel(
        isOpen: isOpen,
        cachedStatusLabel: cachedStatusLabel,
      ),
      amenities: List<String>.from(json['amenities'] as List),
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
      photoReference: json['photoReference'] as String?,
    );
  }

  factory MosqueModel.fromJson(
    Map<String, dynamic> json, {
    required double distanceMeters,
  }) {
    final location = json['geometry']['location'] as Map<String, dynamic>;
    final openingHours = json['opening_hours'] as Map<String, dynamic>?;
    final hasOpenNow = openingHours?.containsKey('open_now') ?? false;
    final rawOpenStatus = openingHours?['open_now'];
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
      distanceMeters: distanceMeters,
      isOpen: _parseOpenStatus(rawOpenStatus),
      statusLabel: _statusLabel(rawOpenStatus, hasOpenNow: hasOpenNow),
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
      'parking': AppStrings.amenityParking,
      'wheelchair_accessible': AppStrings.amenityAccessible,
      'prayer_room': AppStrings.amenityPrayerRoom,
      'wudu': AppStrings.amenityWudu,
    };
    return map[type];
  }

  static bool? _parseOpenStatus(dynamic rawOpenStatus) {
    return rawOpenStatus is bool ? rawOpenStatus : null;
  }

  static String _statusLabel(
    dynamic rawOpenStatus, {
    required bool hasOpenNow,
  }) {
    if (rawOpenStatus is bool) {
      return rawOpenStatus ? AppStrings.statusOpen : AppStrings.statusClosed;
    }
    if (!hasOpenNow || rawOpenStatus == null) {
      return AppStrings.statusNotFound;
    }
    return AppStrings.statusNotValid;
  }

  static String _cachedStatusLabel({
    required bool? isOpen,
    required String? cachedStatusLabel,
  }) {
    if (cachedStatusLabel != null && cachedStatusLabel.trim().isNotEmpty) {
      return cachedStatusLabel;
    }
    if (isOpen == true) return AppStrings.statusOpen;
    if (isOpen == false) return AppStrings.statusClosed;
    return AppStrings.statusNotFound;
  }
}
