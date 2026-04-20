import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mosques_app/core/services/location_service.dart';
import 'package:mosques_app/features/mosque_search/models/mosque_model.dart';
import 'package:mosques_app/features/mosque_search/repo/mosque_search_repo.dart';
import 'mosque_search_states.dart';

class MosqueSearchCubit extends Cubit<MosqueSearchState> {
  final LocationService _locationService;
  final MosqueSearchRepo _repo;

  List<MosqueModel> _all = [];

  MosqueSearchCubit()
      : _locationService = LocationService(),
        _repo = MosqueSearchRepo(),
        super(MosqueSearchInitial());

  Future<void> loadMosques() async {
    try {
      emit(MosqueSearchLocating());
      final position = await _locationService.getCurrentLocation();

      emit(MosqueSearchLoading());
      final mosques = await _repo.fetchNearbyMosques(
        lat: position.latitude,
        lng: position.longitude,
      );

      _all = mosques;
      emit(MosqueSearchSuccess(_all));
    } catch (e) {
      emit(MosqueSearchError(e.toString()));
    }
  }

  void search(String query) {
    if (query.trim().isEmpty) {
      emit(MosqueSearchSuccess(_all));
      return;
    }
    final q = query.toLowerCase();
    final filtered = _all
        .where(
          (m) =>
              m.name.toLowerCase().contains(q) ||
              m.address.toLowerCase().contains(q),
        )
        .toList();
    emit(MosqueSearchSuccess(filtered));
  }
}
