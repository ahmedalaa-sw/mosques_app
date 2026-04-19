class MosqueModel {
  final String name;
  final String address;
  final double rating;
  final String distance;
  final bool isOpen;
  final List<String> amenities;

  const MosqueModel({
    required this.name,
    required this.address,
    required this.rating,
    required this.distance,
    required this.isOpen,
    required this.amenities,
  });
}
