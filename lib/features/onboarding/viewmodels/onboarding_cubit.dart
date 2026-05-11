import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mosques_app/core/data/cities_data.dart';
import 'package:mosques_app/core/services/background_reschedule_service.dart';
import 'package:mosques_app/core/services/shared_location_service.dart';
import 'package:mosques_app/core/utils/app_shared_preferences.dart';
import 'package:mosques_app/core/utils/location_utils.dart';
import 'onboarding_state.dart';

class OnboardingCubit extends Cubit<OnboardingState> {
  static const _kDone            = 'onboarding_done';
  static const kCachedCityName   = 'cached_city_name';
  static const kCachedCityNameAr = 'cached_city_name_ar';
  static const kCachedCountryName   = 'cached_country_name';
  static const kCachedCountryNameAr = 'cached_country_name_ar';

  OnboardingCubit() : super(OnboardingInitial());

  void pickCountry(CountryModel country) => emit(OnboardingCountryPicked(country));

  void pickCity(CityModel city) {
    final current = state;
    final country = current is OnboardingCountryPicked
        ? current.country
        : (current as OnboardingCityPicked).country;
    emit(OnboardingCityPicked(country: country, city: city));
  }

  /// Pre-populates the picker with the previously saved country + city so the
  /// user sees their current selection when opening the change-location screen.
  Future<void> initFromCache() async {
    final countryNameEn = await AppPreferences.getString(kCachedCountryName);
    final cityNameEn    = await AppPreferences.getString(kCachedCityName);

    if (countryNameEn == null) {
      log('[Location] initFromCache: no cached location found', name: 'OnboardingCubit');
      return;
    }

    CountryModel? country;
    for (final c in kCountries) {
      if (c.name == countryNameEn) { country = c; break; }
    }
    if (country == null) {
      log('[Location] initFromCache: country "$countryNameEn" not found in dataset', name: 'OnboardingCubit');
      return;
    }

    if (cityNameEn != null) {
      CityModel? city;
      for (final c in country.cities) {
        if (c.name == cityNameEn) { city = c; break; }
      }
      if (city != null) {
        log('[Location] initFromCache: restored → ${country.name} / ${city.name}', name: 'OnboardingCubit');
        emit(OnboardingCityPicked(country: country, city: city));
        return;
      }
    }

    log('[Location] initFromCache: restored country only → ${country.name}', name: 'OnboardingCubit');
    emit(OnboardingCountryPicked(country));
  }

  /// Saves the selected city coordinates + country code into the same
  /// SharedPreferences keys that HomeCubit reads on startup, so the home
  /// screen loads instantly without any GPS wait.
  Future<void> confirm() async {
    final current = state;
    if (current is! OnboardingCityPicked) return;

    log('[Location] confirm: saving ${current.country.name} / ${current.city.name} '
        '(${current.city.lat}, ${current.city.lng})', name: 'OnboardingCubit');

    SharedLocationService.instance.invalidateCache();
    emit(OnboardingSaving());

    await Future.wait([
      BackgroundRescheduleService.cacheLastLocation(
        current.city.lat,
        current.city.lng,
      ),
      AppPreferences.saveString(LocationUtils.countryCodePrefsKey, current.country.code),
      LocationUtils.updateCoordinateCache(current.city.lat, current.city.lng),
      AppPreferences.saveString(kCachedCityName, current.city.name),
      AppPreferences.saveString(kCachedCityNameAr, current.city.nameAr),
      AppPreferences.saveString(kCachedCountryName, current.country.name),
      AppPreferences.saveString(kCachedCountryNameAr, current.country.nameAr),
      AppPreferences.saveBool(_kDone, value: true),
    ]);

    log('[Location] confirm: saved successfully', name: 'OnboardingCubit');
    emit(OnboardingDone());
  }

  /// Skips city selection and lets HomeCubit fall through to GPS on first load.
  Future<void> skipWithGps() async {
    log('[Location] skipWithGps: user chose GPS-only mode', name: 'OnboardingCubit');
    SharedLocationService.instance.invalidateCache();
    emit(OnboardingSaving());
    await AppPreferences.saveBool(_kDone, value: true);
    emit(OnboardingDone());
  }

  static Future<bool> isOnboardingDone() async =>
      (await AppPreferences.getBool(_kDone)) ?? false;
}
