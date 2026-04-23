import 'package:mosques_app/core/constants/app_strings.dart';
import 'package:mosques_app/core/constants/strings_constants.dart';
import 'package:mosques_app/features/favorite/models/favorite_model.dart';
import 'package:mosques_app/features/favorite/repo/favorite_repo.dart';
import 'package:mosques_app/features/mosque_search/models/mosque_model.dart';

import '../models/mosque_detail_model.dart';

class MosqueDetailsRepo {
  final FavoriteRepo _favoriteRepo = FavoriteRepo.instance;

  MosqueDetailModel buildPreviewDetails(MosqueModel mosque) {
    return MosqueDetailModel(
      id: mosque.id,
      name: mosque.name,
      address: mosque.address,
      latitude: mosque.lat,
      longitude: mosque.lng,
      distanceKm: mosque.distanceMeters / 1000,
      imageUrl: mosque.photoUrl,
      photoReference: mosque.photoReference,
      isOpenNow: mosque.isOpen,
      statusLabel: _detailsStatusLabel(mosque),
      isFavorite: _favoriteRepo.isFavoriteSync(mosque.id),
      amenities: mosque.amenities,
      description:
          'Selected from nearby mosques for your current location.',
    );
  }

  Future<bool> isFavorite(String mosqueId) {
    return _favoriteRepo.isFavorite(mosqueId);
  }

  Future<void> toggleFavorite(MosqueDetailModel mosque) async {
    await _favoriteRepo.setFavorite(
      FavoriteModel.fromMosqueDetails(mosque),
      isFavorite: mosque.isFavorite,
    );
  }

  String _detailsStatusLabel(MosqueModel mosque) {
    if (mosque.isOpen == true) return StringsConstants.openNow;
    if (mosque.isOpen == false) return StringsConstants.closedNow;
    if (mosque.statusLabel == AppStrings.statusNotValid) {
      return StringsConstants.statusNotValid;
    }
    return StringsConstants.statusNotFound;
  }
}
