import 'package:mosques_app/core/constants/app_strings.dart';
import 'package:mosques_app/core/network/endpoint_constants.dart';
import 'package:mosques_app/features/mosque_details/models/mosque_detail_model.dart';
import 'package:mosques_app/features/mosque_search/models/mosque_model.dart';

class FavoriteModel {
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

  const FavoriteModel({
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

  factory FavoriteModel.fromMosqueDetails(MosqueDetailModel mosque) {
    return FavoriteModel(
      id: mosque.id,
      name: mosque.name,
      address: mosque.address,
      distanceMeters: mosque.distanceKm * 1000,
      isOpen: mosque.isOpenNow,
      statusLabel: _searchStatusLabel(mosque),
      amenities: mosque.amenities,
      lat: mosque.latitude,
      lng: mosque.longitude,
      photoReference: mosque.photoReference,
    );
  }

  factory FavoriteModel.fromJson(Map<String, dynamic> json) {
    final isOpen = json['isOpen'] as bool?;
    final statusLabel = json['statusLabel'] as String?;

    return FavoriteModel(
      id: json['id'] as String,
      name: json['name'] as String,
      address: json['address'] as String,
      distanceMeters: (json['distanceMeters'] as num).toDouble(),
      isOpen: isOpen,
      statusLabel: _fallbackStatusLabel(
        isOpen: isOpen,
        statusLabel: statusLabel,
      ),
      amenities: List<String>.from(json['amenities'] as List? ?? const []),
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
      photoReference: json['photoReference'] as String?,
    );
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

  MosqueModel toMosqueModel() {
    return MosqueModel(
      id: id,
      name: name,
      address: address,
      distanceMeters: distanceMeters,
      isOpen: isOpen,
      statusLabel: statusLabel,
      amenities: amenities,
      lat: lat,
      lng: lng,
      photoReference: photoReference,
    );
  }

  static String _searchStatusLabel(MosqueDetailModel mosque) {
    if (mosque.isOpenNow == true) return AppStrings.statusOpen;
    if (mosque.isOpenNow == false) return AppStrings.statusClosed;
    if (mosque.statusLabel == 'Status Not Valid') {
      return AppStrings.statusNotValid;
    }
    return AppStrings.statusNotFound;
  }

  static String _fallbackStatusLabel({
    required bool? isOpen,
    required String? statusLabel,
  }) {
    if (statusLabel != null && statusLabel.trim().isNotEmpty) {
      return statusLabel;
    }
    if (isOpen == true) return AppStrings.statusOpen;
    if (isOpen == false) return AppStrings.statusClosed;
    return AppStrings.statusNotFound;
  }
}
