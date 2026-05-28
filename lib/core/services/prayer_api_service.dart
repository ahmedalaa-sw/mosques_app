import 'package:mosques_app/core/network/dio_helper.dart';
import 'package:mosques_app/features/home/model/prayer_method_mapper.dart';
import 'package:mosques_app/core/utils/timezone_resolver.dart';
import 'package:mosques_app/features/home/model/home_model.dart';

class PrayerApiService {
  PrayerApiService._();

  static const _baseUrl = 'https://api.aladhan.com/v1/timings';

  static Future<AladhanPrayerTimesModel> fetchPrayerTimes({
    required double latitude,
    required double longitude,
    required String countryCode,
    required String ianaTimezone,
    DateTime? date,
    double altitude = 0,
  }) async {
    final effectiveDate = date ?? TimezoneResolver.todayAt(ianaTimezone);
    final timestamp = effectiveDate.toUtc().millisecondsSinceEpoch ~/ 1000;
    final method = PrayerMethodMapper.apiMethodForCountry(countryCode);
    final methodName = PrayerMethodMapper.methodNameForCountry(countryCode);
    final queryParams = {
      'latitude': latitude,
      'longitude': longitude,
      'method': method,
      'school': 0,
      'timezonestring': ianaTimezone,
      'highLatitudeRule': PrayerMethodMapper.useHighLatitudeRule(latitude)
          ? 1
          : 0,
      'adjustment': 0,
    };

    final response = await DioHelper.getData(
      endpoint: '$_baseUrl/$timestamp',
      queryParameters: queryParams,
    );

    if (response.statusCode != 200) {
      throw Exception('AlAdhan API response status ${response.statusCode}');
    }

    final payload = response.data;
    if (payload == null || payload is! Map<String, dynamic>) {
      throw Exception('AlAdhan API returned malformed data');
    }

    final data = payload['data'];
    if (data == null || data is! Map<String, dynamic>) {
      throw Exception('AlAdhan API missing data payload');
    }

    final timings = data['timings'];
    if (timings == null || timings is! Map<String, dynamic>) {
      throw Exception('AlAdhan API missing timings');
    }

    return AladhanPrayerTimesModel.fromApiResponse(
      latitude: latitude,
      longitude: longitude,
      altitude: altitude,
      date: effectiveDate,
      ianaTimezone: ianaTimezone,
      countryCode: countryCode,
      methodName: methodName,
      source: 'api',
      timings: timings.map((key, value) => MapEntry(key, value.toString())),
    );
  }
}
