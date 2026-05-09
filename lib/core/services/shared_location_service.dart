import 'package:geolocator/geolocator.dart';
import 'location_service.dart';

/// Singleton that de-duplicates concurrent [getCurrentLocation] calls.
///
/// When multiple cubits request the device position at the same time only
/// one GPS call is made; all callers share the same [Future] and receive
/// the same [Position]. The result is also cached for [_cacheDuration] so
/// rapid sequential calls skip a second hardware round-trip.
class SharedLocationService {
  SharedLocationService._();
  static final SharedLocationService instance = SharedLocationService._();

  static const _cacheDuration = Duration(seconds: 30);

  final _inner = LocationService();
  Future<Position>? _pending;
  Position? _cached;
  DateTime? _cachedAt;

  Future<Position> getCurrentLocation() async {
    final cached = _cached;
    final cachedAt = _cachedAt;
    if (cached != null &&
        cachedAt != null &&
        DateTime.now().difference(cachedAt) < _cacheDuration) {
      return cached;
    }

    // De-duplicate: if a request is already in flight return the same Future.
    _pending ??= _fetchAndCache();
    try {
      return await _pending!;
    } finally {
      _pending = null;
    }
  }

  /// Call this when you know the cached position is stale (e.g. after a long
  /// app backgrounding) so the next [getCurrentLocation] hits the GPS.
  void invalidateCache() {
    _cached = null;
    _cachedAt = null;
  }

  Future<Position> _fetchAndCache() async {
    final pos = await _inner.getCurrentLocation();
    _cached = pos;
    _cachedAt = DateTime.now();
    return pos;
  }
}
