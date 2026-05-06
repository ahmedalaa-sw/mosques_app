import 'package:mosques_app/core/constants/strings_constants.dart';

class MosqueDetailModel {
  final String id;
  final String name;
  final String? arabicName;
  final String address;
  final double latitude;
  final double longitude;
  final double distanceKm;
  final double rating;
  final int reviewCount;
  final String? imageUrl;
  final String? photoReference;
  final String? phoneNumber;
  final String? website;
  final String? description;
  final bool? isOpenNow;
  final String statusLabel;
  final bool isFavorite;
  final List<String> amenities;
  final Map<String, String> prayerTimes;
  final int? capacity;

  const MosqueDetailModel({
    required this.id,
    required this.name,
    this.arabicName,
    required this.address,
    required this.latitude,
    required this.longitude,
    this.distanceKm = 0.0,
    this.rating = 0.0,
    this.reviewCount = 0,
    this.imageUrl,
    this.photoReference,
    this.phoneNumber,
    this.website,
    this.description,
    this.isOpenNow,
    this.statusLabel = StringsConstants.statusNotFound,
    this.isFavorite = false,
    this.amenities = const [],
    this.prayerTimes = const {},
    this.capacity,
  });

  factory MosqueDetailModel.fromJson(Map<String, dynamic> json) {
    return MosqueDetailModel(
      id: json['id'] as String,
      name: json['name'] as String,
      arabicName: json['arabic_name'] as String?,
      address: json['address'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      distanceKm: (json['distance_km'] as num?)?.toDouble() ?? 0.0,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: json['review_count'] as int? ?? 0,
      imageUrl: json['image_url'] as String?,
      photoReference: json['photo_reference'] as String?,
      phoneNumber: json['phone_number'] as String?,
      website: json['website'] as String?,
      description: json['description'] as String?,
      isOpenNow: json['is_open_now'] as bool?,
      statusLabel:
          json['status_label'] as String? ?? StringsConstants.statusNotFound,
      isFavorite: json['is_favorite'] as bool? ?? false,
      amenities: List<String>.from(json['amenities'] as List? ?? const []),
      prayerTimes: Map<String, String>.from(json['prayer_times'] as Map? ?? {}),
      capacity: json['capacity'] as int?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'arabic_name': arabicName,
        'address': address,
        'latitude': latitude,
        'longitude': longitude,
        'distance_km': distanceKm,
        'rating': rating,
        'review_count': reviewCount,
        'image_url': imageUrl,
        'photo_reference': photoReference,
        'phone_number': phoneNumber,
        'website': website,
        'description': description,
        'is_open_now': isOpenNow,
        'status_label': statusLabel,
        'is_favorite': isFavorite,
        'amenities': amenities,
        'prayer_times': prayerTimes,
        'capacity': capacity,
      };

  MosqueDetailModel copyWith({bool? isFavorite}) => MosqueDetailModel(
        id: id,
        name: name,
        arabicName: arabicName,
        address: address,
        latitude: latitude,
        longitude: longitude,
        distanceKm: distanceKm,
        rating: rating,
        reviewCount: reviewCount,
        imageUrl: imageUrl,
        photoReference: photoReference,
        phoneNumber: phoneNumber,
        website: website,
        description: description,
        isOpenNow: isOpenNow,
        statusLabel: statusLabel,
        isFavorite: isFavorite ?? this.isFavorite,
        amenities: amenities,
        prayerTimes: prayerTimes,
        capacity: capacity,
      );
}
