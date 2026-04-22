import '../models/mosque_detail_model.dart';

class MosqueDetailsRepo {
  // TODO: inject ApiConsumer / SupabaseService when APIs are wired up
  Future<MosqueDetailModel> fetchMosqueDetails(String mosqueId) async {
    // Simulated delay — replace with real Google Places / Supabase call
    await Future.delayed(const Duration(milliseconds: 800));
    return MosqueDetailModel(
      id: mosqueId,
      name: 'Al-Rahman Mosque',
      arabicName: 'مسجد الرحمن',
      address: '123 Islamic Center Blvd, Cairo, Egypt',
      latitude: 30.0444,
      longitude: 31.2357,
      distanceKm: 1.2,
      rating: 4.8,
      reviewCount: 234,
      phoneNumber: '+20 2 1234 5678',
      website: 'https://alrahman-mosque.org',
      description:
          'Al-Rahman Mosque is a historic community mosque serving worshippers since 1965. '
          'It features stunning Islamic architecture with hand-painted geometric patterns, '
          'a serene courtyard, and dedicated spaces for learning and reflection.',
      isOpenNow: true,
      capacity: 1500,
      prayerTimes: const {
        'Fajr': '05:12',
        'Dhuhr': '12:34',
        'Asr': '15:48',
        'Maghrib': '18:22',
        'Isha': '19:52',
      },
    );
  }

  Future<void> toggleFavorite(String mosqueId, {required bool isFavorite}) async {
    // TODO: persist to Hive favoritesBox
    await Future.delayed(const Duration(milliseconds: 200));
  }
}
