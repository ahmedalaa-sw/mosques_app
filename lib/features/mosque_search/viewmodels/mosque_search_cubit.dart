import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mosques_app/core/services/location_service.dart';
import 'package:mosques_app/core/utils/app_shared_preferences.dart';
import 'package:mosques_app/features/mosque_search/models/mosque_model.dart';
import 'package:mosques_app/features/mosque_search/repo/mosque_search_repo.dart';
import 'mosque_search_states.dart';

class MosqueSearchCubit extends Cubit<MosqueSearchState> {
  final LocationService _locationService;
  final MosqueSearchRepo _repo;

  List<MosqueModel> _all = [];

  static const _kCachedLat = 'cached_lat';
  static const _kCachedLng = 'cached_lng';
  static const _kCachedMosques = 'cached_mosques';
  static const _kLocationThresholdMeters = 1000.0;

  MosqueSearchCubit()
      : _locationService = LocationService(),
        _repo = MosqueSearchRepo(),
        super(MosqueSearchInitial());

  Future<void> loadMosques() async {
    try {
      emit(MosqueSearchLocating());
      final position = await _locationService.getCurrentLocation();

      final cached = await _tryLoadFromCache(position);
      if (cached != null) {
        _all = cached;
        emit(MosqueSearchSuccess(_all));
        return;
      }

      emit(MosqueSearchLoading());
      final mosques = await _repo.fetchNearbyMosques(
        lat: position.latitude,
        lng: position.longitude,
      );

      await _saveToCache(position, mosques);
      _all = mosques;
      emit(MosqueSearchSuccess(_all));
    } catch (e) {
      emit(MosqueSearchError(e.toString()));
    }
  }

  Future<List<MosqueModel>?> _tryLoadFromCache(Position pos) async {
    final cachedLat = await AppPreferences.getDouble(_kCachedLat);
    final cachedLng = await AppPreferences.getDouble(_kCachedLng);
    if (cachedLat == null || cachedLng == null) return null;

    final distance = Geolocator.distanceBetween(
      pos.latitude,
      pos.longitude,
      cachedLat,
      cachedLng,
    );
    if (distance >= _kLocationThresholdMeters) return null;

    final json = await AppPreferences.getString(_kCachedMosques);
    if (json == null) return null;

    final list = jsonDecode(json) as List<dynamic>;
    return list
        .map((e) => MosqueModel.fromCache(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> _saveToCache(Position pos, List<MosqueModel> mosques) async {
    await AppPreferences.saveDouble(_kCachedLat, pos.latitude);
    await AppPreferences.saveDouble(_kCachedLng, pos.longitude);
    await AppPreferences.saveString(
      _kCachedMosques,
      jsonEncode(mosques.map((m) => m.toJson()).toList()),
    );
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
