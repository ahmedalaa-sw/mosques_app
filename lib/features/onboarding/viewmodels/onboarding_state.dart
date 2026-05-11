import 'package:mosques_app/core/data/cities_data.dart';

abstract class OnboardingState {}

class OnboardingInitial extends OnboardingState {}

class OnboardingCountryPicked extends OnboardingState {
  final CountryModel country;
  OnboardingCountryPicked(this.country);
}

class OnboardingCityPicked extends OnboardingState {
  final CountryModel country;
  final CityModel city;
  OnboardingCityPicked({required this.country, required this.city});
}

class OnboardingSaving extends OnboardingState {}

class OnboardingDone extends OnboardingState {}
