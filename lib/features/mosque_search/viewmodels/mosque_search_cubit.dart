import 'dart:async';
import 'dart:convert';

import 'package:arabic_search/arabic_search.dart';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mosques_app/core/constants/app_constants.dart';
import 'package:mosques_app/core/services/location_service.dart';
import 'package:mosques_app/core/services/shared_location_service.dart';
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

  /// Loads nearby mosques.
  ///
  /// [position] — when called from a stream update the position is already
  /// known and passed directly, avoiding a redundant GPS round-trip.
  /// When called for the initial load [position] is null and the shared
  /// location service fetches it (deduplicating any concurrent requests).
  Future<void> loadMosques({Position? position}) async {
    try {
      emit(MosqueSearchLocating());
      final pos =
          position ?? await SharedLocationService.instance.getCurrentLocation();
      _lastFetchPosition = pos;

      final cached = await _tryLoadFromCache(pos);
      if (cached != null) {
        _all = cached;
        emit(MosqueSearchSuccess(_all));
        return;
      }

      emit(MosqueSearchLoading());
      final mosques = await _repo.fetchNearbyMosques(
        lat: pos.latitude,
        lng: pos.longitude,
      );

      await _saveToCache(pos, mosques);
      _all = mosques;
      emit(MosqueSearchSuccess(_all));
    } catch (e) {
      final (message, canRetry, errorType) = _parseError(e);
      emit(MosqueSearchError(message, canRetry: canRetry, errorType: errorType));
    }
  }

  (String, bool, MosqueErrorType) _parseError(Object error) {
    if (error is DioException) {
      return switch (error.type) {
        DioExceptionType.connectionTimeout ||
        DioExceptionType.sendTimeout ||
        DioExceptionType.receiveTimeout =>
          ('search_timeout'.tr(), true, MosqueErrorType.network),
        DioExceptionType.connectionError =>
          ('search_no_internet'.tr(), true, MosqueErrorType.network),
        DioExceptionType.badResponse =>
          ('search_server_error'.tr(), false, MosqueErrorType.server),
        _ => ('search_timeout'.tr(), true, MosqueErrorType.network),
      };
    }
    if (error is LocationServiceDisabledException) {
      return ('location_services_disabled'.tr(), true, MosqueErrorType.location);
    }
    if (error is PermissionDeniedException) {
      final permanently = error.message?.contains('permanently') ?? false;
      return (
        permanently
            ? 'location_permission_permanently_denied'.tr()
            : 'location_permission_denied'.tr(),
        !permanently,
        MosqueErrorType.location,
      );
    }
    return ('search_server_error'.tr(), true, MosqueErrorType.network);
  }

  void _onPositionUpdate(Position position) {
    // Guard: don't interrupt an ongoing locate / fetch.
    if (state is MosqueSearchLocating || state is MosqueSearchLoading) return;

    if (_lastFetchPosition == null) {
      loadMosques(position: position);
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
      // Pass the already-known stream position — no extra GPS call needed.
      loadMosques(position: position);
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
