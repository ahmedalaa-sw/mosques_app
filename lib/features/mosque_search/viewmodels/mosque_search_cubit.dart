import 'dart:async';
import 'dart:convert';

import 'package:arabic_search/arabic_search.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mosques_app/core/constants/app_constants.dart';
import 'package:mosques_app/core/services/location_service.dart';
import 'package:mosques_app/core/utils/app_shared_preferences.dart';
import 'package:mosques_app/features/mosque_search/models/mosque_model.dart';
import 'package:mosques_app/features/mosque_search/repo/mosque_search_repo.dart';
import 'mosque_search_states.dart';

class MosqueSearchCubit extends Cubit<MosqueSearchState> {
  final LocationService _locationService;
  final MosqueSearchRepo _repo;

  List<MosqueModel> _all = [];
  Position? _lastFetchPosition;
  StreamSubscription<Position>? _positionSubscription;

  static const _kCachedLat = AppConstants.cachedLat;
  static const _kCachedLng = AppConstants.cachedLng;
  static const _kCachedMosques = AppConstants.cachedMosques;
  static const _kLocationThresholdMeters = AppConstants.locationThresholdMeters;
  static const _kStreamDistanceFilter =
      AppConstants.locationStreamDistanceFilterMeters;

  MosqueSearchCubit()
    : _locationService = LocationService(),
      _repo = MosqueSearchRepo(),
      super(MosqueSearchInitial());

  /// Starts continuous location tracking and triggers an immediate initial load.
  ///
  /// Idempotent — calling again while already tracking is a no-op.
  /// On each OS-filtered position update (every [_kStreamDistanceFilter] m),
  /// checks if the user has moved more than [_kLocationThresholdMeters] from
  /// the last fetch point; if so, re-fetches from the API automatically.
  Future<void> startTracking() async {
    if (_positionSubscription != null) return;

    _positionSubscription = _locationService
        .getPositionStream(distanceFilter: _kStreamDistanceFilter)
        .listen(_onPositionUpdate, onError: _onStreamError);

    await loadMosques();
  }

  void stopTracking() {
    _positionSubscription?.cancel();
    _positionSubscription = null;
  }

  Future<void> loadMosques() async {
    try {
      emit(MosqueSearchLocating());
      final position = await _locationService.getCurrentLocation();
      _lastFetchPosition = position;

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

  void _onPositionUpdate(Position position) {
    // Guard: don't interrupt an ongoing locate / fetch.
    if (state is MosqueSearchLocating || state is MosqueSearchLoading) return;

    if (_lastFetchPosition == null) {
      loadMosques();
      return;
    }

    final distance = Geolocator.distanceBetween(
      _lastFetchPosition!.latitude,
      _lastFetchPosition!.longitude,
      position.latitude,
      position.longitude,
    );

    debugPrint(
      '[MosqueSearchCubit] Position update — '
      'moved ${distance.toStringAsFixed(1)} m from last fetch '
      '(threshold: $_kLocationThresholdMeters m)',
    );

    if (distance >= _kLocationThresholdMeters) {
      debugPrint('[MosqueSearchCubit] Threshold exceeded — re-fetching mosques');
      loadMosques();
    }
  }

  void _onStreamError(Object error) {
    debugPrint('[MosqueSearchCubit] Position stream error: $error');
  }

  Future<List<MosqueModel>?> _tryLoadFromCache(Position pos) async {
    debugPrint(
      '🔍 [Cache] Current GPS → lat:${pos.latitude}, lng:${pos.longitude}',
    );

    final [cachedLat, cachedLng] = await Future.wait([
      AppPreferences.getDouble(_kCachedLat),
      AppPreferences.getDouble(_kCachedLng),
    ]);

    if (cachedLat == null || cachedLng == null) {
      debugPrint('🔍 [Cache] No cached location found → will call API');
      return null;
    }

    debugPrint('🔍 [Cache] Cached GPS → lat:$cachedLat, lng:$cachedLng');

    final distance = Geolocator.distanceBetween(
      pos.latitude,
      pos.longitude,
      cachedLat,
      cachedLng,
    );

    debugPrint(
      '🔍 [Cache] Distance from cache: ${distance.toStringAsFixed(1)} m  '
      '(threshold: ${_kLocationThresholdMeters.toInt()} m)',
    );

    if (distance >= _kLocationThresholdMeters) {
      debugPrint('❌ [Cache] MISS — moved too far, calling API');
      return null;
    }

    final json = await AppPreferences.getString(_kCachedMosques);
    if (json == null) {
      debugPrint('❌ [Cache] MISS — no cached results, calling API');
      return null;
    }

    final list = jsonDecode(json) as List<dynamic>;
    debugPrint(
      '✅ [Cache] HIT — loading ${list.length} mosques from cache, skipping API',
    );
    return list
        .map((e) => MosqueModel.fromCache(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> _saveToCache(Position pos, List<MosqueModel> mosques) async {
    await Future.wait([
      AppPreferences.saveDouble(_kCachedLat, pos.latitude),
      AppPreferences.saveDouble(_kCachedLng, pos.longitude),
      AppPreferences.saveString(
        _kCachedMosques,
        jsonEncode(mosques.map((m) => m.toJson()).toList()),
      ),
    ]);
    debugPrint(
      '💾 [Cache] Saved ${mosques.length} mosques at '
      'lat:${pos.latitude}, lng:${pos.longitude}',
    );
  }

  void search(String query) {
    final trimmedQuery = query.trim();
    if (trimmedQuery.isEmpty) {
      emit(MosqueSearchSuccess(_all));
      return;
    }

    final filtered = _all
        .where(
          (m) =>
              ArabicText.containsNormalized(m.name, trimmedQuery) ||
              ArabicText.containsNormalized(m.address, trimmedQuery),
        )
        .toList();
    emit(MosqueSearchSuccess(filtered));
  }

  @override
  Future<void> close() {
    _positionSubscription?.cancel();
    return super.close();
  }
}
