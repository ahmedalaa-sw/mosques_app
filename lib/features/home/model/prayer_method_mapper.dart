import 'package:adhan_dart/adhan_dart.dart';

class PrayerMethodMapper {
  /// Maps country code to calculation parameters with proper high latitude handling.
  static CalculationParameters fromCountry(String code, {double latitude = 0}) {
    final params = _getBaseParameters(code);

    // Apply high latitude rule for regions near poles
    if (latitude.abs() > 65) {
      params.highLatitudeRule = HighLatitudeRule.middleOfTheNight;
      if (latitude.abs() > 75) {
        params.highLatitudeRule = HighLatitudeRule.middleOfTheNight;
      }
    }

    return params;
  }

  static bool useHighLatitudeRule(double latitude) => latitude.abs() > 65;

  static int apiMethodForCountry(String code) {
    switch (code.toUpperCase()) {
      case 'EG':
        return 5; // Egyptian
      case 'SA':
      case 'KW':
      case 'AE':
      case 'QA':
      case 'BH':
        return 4; // Umm Al-Qura
      case 'PK':
      case 'IN':
      case 'BD':
        return 1; // Karachi
      case 'MY':
      case 'ID':
      case 'SG':
        return 11; // Singapore
      case 'TR':
        return 13; // Turkey
      case 'US':
      case 'CA':
        return 2; // ISNA / North America
      default:
        return 2; // Muslim World League fallback
    }
  }

  static String methodNameForCountry(String code) {
    switch (code.toUpperCase()) {
      case 'EG':
        return 'Egyptian';
      case 'SA':
      case 'KW':
      case 'AE':
      case 'QA':
      case 'BH':
        return 'Umm Al-Qura';
      case 'PK':
      case 'IN':
      case 'BD':
        return 'Karachi';
      case 'MY':
      case 'ID':
      case 'SG':
        return 'Singapore';
      case 'TR':
        return 'Turkiye';
      case 'US':
      case 'CA':
        return 'North America';
      default:
        return 'Muslim World League';
    }
  }

  static CalculationParameters _getBaseParameters(String code) {
    switch (code) {
      case 'EG':
        return CalculationMethodParameters.egyptian();

      case 'SA':
      case 'KW':
      case 'AE':
      case 'QA':
      case 'BH':
        return CalculationMethodParameters.ummAlQura();

      case 'PK':
      case 'IN':
      case 'BD':
        return CalculationMethodParameters.karachi();

      case 'MY':
      case 'ID':
      case 'SG':
        return CalculationMethodParameters.singapore();

      case 'TR':
        return CalculationMethodParameters.turkiye();

      case 'US':
      case 'CA':
        // ISNA-style convention for North America (adhan_dart: northAmerica).
        return CalculationMethodParameters.northAmerica();

      default:
        return CalculationMethodParameters.muslimWorldLeague();
    }
  }
}
