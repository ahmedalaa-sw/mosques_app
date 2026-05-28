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