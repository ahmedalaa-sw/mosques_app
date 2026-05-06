import 'package:adhan_dart/adhan_dart.dart';

class PrayerMethodMapper {
  static CalculationParameters fromCountry(String code) {
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

      default:
        return CalculationMethodParameters.muslimWorldLeague();
    }
  }
}
