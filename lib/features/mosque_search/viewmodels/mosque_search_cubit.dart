import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mosques_app/features/mosque_search/models/mosque_model.dart';
import 'mosque_search_states.dart';

class MosqueSearchCubit extends Cubit<MosqueSearchState> {
  MosqueSearchCubit() : super(MosqueSearchInitial());

  List<MosqueModel> _all = [];

  static const List<MosqueModel> _dummyMosques = [
    MosqueModel(
      name: 'Al-Nur Grand Mosque',
      address: 'Islamic Quarter, District 1',
      rating: 4.9,
      distance: '0.8 km away',
      isOpen: true,
      amenities: [],
    ),
    MosqueModel(
      name: 'Sultan Ahmed Center',
      address: 'Al-Azhar Street, District 3',
      rating: 4.7,
      distance: '2.4 km away',
      isOpen: false,
      amenities: ['Wudhu Facilities'],
    ),
    MosqueModel(
      name: 'Masjid Al-Rahman',
      address: 'Nile Corniche, Block 7',
      rating: 4.5,
      distance: '1.2 km away',
      isOpen: true,
      amenities: ['Parking'],
    ),
    MosqueModel(
      name: 'Islamic Center Cairo',
      address: 'Tahrir Square, Central',
      rating: 4.8,
      distance: '3.1 km away',
      isOpen: true,
      amenities: ['AC', 'Quran Classes'],
    ),
    MosqueModel(
      name: 'Masjid Al-Taqwa',
      address: 'Garden City, South District',
      rating: 4.6,
      distance: '0.5 km away',
      isOpen: true,
      amenities: ["Sisters' Section"],
    ),
    MosqueModel(
      name: 'Al-Fath Mosque',
      address: 'Ramsis Square, District 2',
      rating: 4.3,
      distance: '4.0 km away',
      isOpen: false,
      amenities: ['Library'],
    ),
  ];

  void loadMosques() {
    emit(MosqueSearchLoading());
    _all = List.from(_dummyMosques);
    emit(MosqueSearchSuccess(_all));
  }

  void search(String query) {
    if (query.trim().isEmpty) {
      emit(MosqueSearchSuccess(_all));
      return;
    }
    final q = query.toLowerCase();
    final filtered = _all
        .where((m) =>
            m.name.toLowerCase().contains(q) ||
            m.address.toLowerCase().contains(q))
        .toList();
    emit(MosqueSearchSuccess(filtered));
  }
}
