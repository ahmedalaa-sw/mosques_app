import 'package:hive_flutter/hive_flutter.dart';
import 'package:mosques_app/features/favorite/models/favorite_model.dart';

class FavoriteRepo {
  FavoriteRepo._();

  static final FavoriteRepo instance = FavoriteRepo._();
  static const String boxName = 'favoritesBox';

  Future<Box<Map>> _openBox() async {
    if (Hive.isBoxOpen(boxName)) {
      return Hive.box<Map>(boxName);
    }
    return Hive.openBox<Map>(boxName);
  }

  Future<List<FavoriteModel>> getFavorites() async {
    final box = await _openBox();
    return _readFavorites(box);
  }

  Stream<List<FavoriteModel>> watchFavorites() async* {
    final box = await _openBox();
    yield _readFavorites(box);
    yield* box.watch().map((_) => _readFavorites(box));
  }

  Future<void> setFavorite(
    FavoriteModel favorite, {
    required bool isFavorite,
  }) async {
    final box = await _openBox();
    if (isFavorite) {
      await box.put(favorite.id, favorite.toJson());
      return;
    }
    await box.delete(favorite.id);
  }

  Future<bool> isFavorite(String mosqueId) async {
    final box = await _openBox();
    return box.containsKey(mosqueId);
  }

  bool isFavoriteSync(String mosqueId) {
    if (!Hive.isBoxOpen(boxName)) {
      return false;
    }
    return Hive.box<Map>(boxName).containsKey(mosqueId);
  }

  List<FavoriteModel> _readFavorites(Box<Map> box) {
    final favorites = box.values
        .map(
          (item) => FavoriteModel.fromJson(
            Map<String, dynamic>.from(item.cast<dynamic, dynamic>()),
          ),
        )
        .toList()
      ..sort((a, b) => a.name.compareTo(b.name));
    return favorites;
  }
}
