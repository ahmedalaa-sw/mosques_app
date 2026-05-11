class CityModel {
  final String name;
  final String nameAr;
  final double lat;
  final double lng;

  const CityModel({
    required this.name,
    required this.nameAr,
    required this.lat,
    required this.lng,
  });
}

class CountryModel {
  final String name;
  final String nameAr;
  final String code; // ISO 3166-1 alpha-2
  final List<CityModel> cities;

  const CountryModel({
    required this.name,
    required this.nameAr,
    required this.code,
    required this.cities,
  });
}

const List<CountryModel> kCountries = [
  CountryModel(
    name: 'Algeria',
    nameAr: 'الجزائر',
    code: 'DZ',
    cities: [
      CityModel(name: 'Algiers',     nameAr: 'الجزائر',    lat: 36.7525,  lng: 3.0420),
      CityModel(name: 'Annaba',      nameAr: 'عنابة',      lat: 36.9000,  lng: 7.7667),
      CityModel(name: 'Constantine', nameAr: 'قسنطينة',    lat: 36.3650,  lng: 6.6147),
      CityModel(name: 'Oran',        nameAr: 'وهران',      lat: 35.6969,  lng: -0.6331),
      CityModel(name: 'Tlemcen',     nameAr: 'تلمسان',     lat: 34.8828,  lng: -1.3153),
    ],
  ),
  CountryModel(
    name: 'Australia',
    nameAr: 'أستراليا',
    code: 'AU',
    cities: [
      CityModel(name: 'Brisbane',  nameAr: 'بريزبان',  lat: -27.4698, lng: 153.0251),
      CityModel(name: 'Melbourne', nameAr: 'ملبورن',   lat: -37.8136, lng: 144.9631),
      CityModel(name: 'Perth',     nameAr: 'بيرث',     lat: -31.9505, lng: 115.8605),
      CityModel(name: 'Sydney',    nameAr: 'سيدني',    lat: -33.8688, lng: 151.2093),
    ],
  ),
  CountryModel(
    name: 'Bahrain',
    nameAr: 'البحرين',
    code: 'BH',
    cities: [
      CityModel(name: 'Manama',   nameAr: 'المنامة',  lat: 26.2285, lng: 50.5860),
      CityModel(name: 'Muharraq', nameAr: 'المحرق',   lat: 26.2536, lng: 50.6100),
      CityModel(name: 'Riffa',    nameAr: 'الرفاع',   lat: 26.1300, lng: 50.5550),
    ],
  ),
  CountryModel(
    name: 'Bangladesh',
    nameAr: 'بنغلاديش',
    code: 'BD',
    cities: [
      CityModel(name: 'Chittagong', nameAr: 'شيتاغونغ', lat: 22.3569, lng: 91.7832),
      CityModel(name: 'Dhaka',      nameAr: 'دكا',       lat: 23.8103, lng: 90.4125),
      CityModel(name: 'Khulna',     nameAr: 'خولنا',     lat: 22.8456, lng: 89.5403),
      CityModel(name: 'Sylhet',     nameAr: 'سيلهيت',    lat: 24.8949, lng: 91.8687),
    ],
  ),
  CountryModel(
    name: 'Canada',
    nameAr: 'كندا',
    code: 'CA',
    cities: [
      CityModel(name: 'Calgary',     nameAr: 'كالغاري',    lat: 51.0447,  lng: -114.0719),
      CityModel(name: 'Mississauga', nameAr: 'ميسيساغا',   lat: 43.5890,  lng: -79.6441),
      CityModel(name: 'Montreal',    nameAr: 'مونتريال',   lat: 45.5017,  lng: -73.5673),
      CityModel(name: 'Ottawa',      nameAr: 'أوتاوا',     lat: 45.4215,  lng: -75.6972),
      CityModel(name: 'Toronto',     nameAr: 'تورونتو',    lat: 43.6532,  lng: -79.3832),
      CityModel(name: 'Vancouver',   nameAr: 'فانكوفر',    lat: 49.2827,  lng: -123.1207),
    ],
  ),
  CountryModel(
    name: 'Egypt',
    nameAr: 'مصر',
    code: 'EG',
    cities: [
      CityModel(name: 'Alexandria',          nameAr: 'الإسكندرية',        lat: 31.2001,  lng: 29.9187),
      CityModel(name: 'Aswan',               nameAr: 'أسوان',             lat: 24.0889,  lng: 32.8998),
      CityModel(name: 'Asyut',               nameAr: 'أسيوط',             lat: 27.1810,  lng: 31.1837),
      CityModel(name: 'Badr City',           nameAr: 'مدينة بدر',         lat: 30.1310,  lng: 31.7203),
      CityModel(name: 'Beni Suef',           nameAr: 'بني سويف',          lat: 29.0661,  lng: 31.0994),
      CityModel(name: 'Cairo',               nameAr: 'القاهرة',           lat: 30.0444,  lng: 31.2357),
      CityModel(name: 'Damietta',            nameAr: 'دمياط',             lat: 31.4165,  lng: 31.8133),
      CityModel(name: 'El Hawamdeya',        nameAr: 'الحوامدية',         lat: 29.8358,  lng: 31.2489),
      CityModel(name: 'El Mahalla El Kubra', nameAr: 'المحلة الكبرى',     lat: 30.9750,  lng: 31.1639),
      CityModel(name: 'Fayoum',              nameAr: 'الفيوم',            lat: 29.3084,  lng: 30.8428),
      CityModel(name: 'Giza',                nameAr: 'الجيزة',            lat: 30.0131,  lng: 31.2089),
      CityModel(name: 'Heliopolis',          nameAr: 'مصر الجديدة',       lat: 30.0899,  lng: 31.3422),
      CityModel(name: 'Helwan',              nameAr: 'حلوان',             lat: 29.8500,  lng: 31.3333),
      CityModel(name: 'Hurghada',            nameAr: 'الغردقة',           lat: 27.2579,  lng: 33.8116),
      CityModel(name: 'Ismailia',            nameAr: 'الإسماعيلية',       lat: 30.5965,  lng: 32.2715),
      CityModel(name: 'Kafr El Sheikh',      nameAr: 'كفر الشيخ',         lat: 31.1107,  lng: 30.9388),
      CityModel(name: 'Luxor',               nameAr: 'الأقصر',            lat: 25.6872,  lng: 32.6396),
      CityModel(name: 'Mansoura',            nameAr: 'المنصورة',          lat: 31.0364,  lng: 31.3807),
      CityModel(name: 'Marsa Matruh',        nameAr: 'مرسى مطروح',        lat: 31.3543,  lng: 27.2373),
      CityModel(name: 'Minya',               nameAr: 'المنيا',            lat: 28.1099,  lng: 30.7503),
      CityModel(name: 'New Cairo',           nameAr: 'القاهرة الجديدة',   lat: 30.0131,  lng: 31.4961),
      CityModel(name: 'Obour City',          nameAr: 'مدينة العبور',      lat: 30.2035,  lng: 31.4720),
      CityModel(name: 'Port Said',           nameAr: 'بورسعيد',           lat: 31.2565,  lng: 32.2841),
      CityModel(name: 'Qena',                nameAr: 'قنا',               lat: 26.1551,  lng: 32.7160),
      CityModel(name: 'Qalyub',              nameAr: 'قليوب',             lat: 30.1833,  lng: 31.2000),
      CityModel(name: 'Sharm El Sheikh',     nameAr: 'شرم الشيخ',         lat: 27.9158,  lng: 34.3299),
      CityModel(name: 'Shebin El Kom',       nameAr: 'شبين الكوم',        lat: 30.5500,  lng: 31.0167),
      CityModel(name: 'Sixth of October',    nameAr: 'السادس من أكتوبر',  lat: 29.9297,  lng: 30.9273),
      CityModel(name: 'Sohag',               nameAr: 'سوهاج',             lat: 26.5522,  lng: 31.6949),
      CityModel(name: 'Suez',                nameAr: 'السويس',            lat: 29.9668,  lng: 32.5498),
      CityModel(name: 'Tanta',               nameAr: 'طنطا',              lat: 30.7865,  lng: 30.9976),
      CityModel(name: 'Tenth of Ramadan',    nameAr: 'العاشر من رمضان',   lat: 30.2980,  lng: 31.7540),
      CityModel(name: 'Zagazig',             nameAr: 'الزقازيق',          lat: 30.5833,  lng: 31.5000),
    ],
  ),
  CountryModel(
    name: 'France',
    nameAr: 'فرنسا',
    code: 'FR',
    cities: [
      CityModel(name: 'Lyon',      nameAr: 'ليون',     lat: 45.7640, lng: 4.8357),
      CityModel(name: 'Marseille', nameAr: 'مرسيليا',  lat: 43.2965, lng: 5.3698),
      CityModel(name: 'Paris',     nameAr: 'باريس',    lat: 48.8566, lng: 2.3522),
      CityModel(name: 'Strasbourg',nameAr: 'ستراسبورغ',lat: 48.5734, lng: 7.7521),
    ],
  ),
  CountryModel(
    name: 'Germany',
    nameAr: 'ألمانيا',
    code: 'DE',
    cities: [
      CityModel(name: 'Berlin',    nameAr: 'برلين',    lat: 52.5200,  lng: 13.4050),
      CityModel(name: 'Cologne',   nameAr: 'كولونيا',  lat: 50.9333,  lng: 6.9500),
      CityModel(name: 'Dortmund',  nameAr: 'دورتموند', lat: 51.5136,  lng: 7.4653),
      CityModel(name: 'Frankfurt', nameAr: 'فرانكفورت',lat: 50.1109,  lng: 8.6821),
      CityModel(name: 'Hamburg',   nameAr: 'هامبورغ',  lat: 53.5753,  lng: 10.0153),
      CityModel(name: 'Munich',    nameAr: 'ميونخ',    lat: 48.1351,  lng: 11.5820),
    ],
  ),
  CountryModel(
    name: 'Indonesia',
    nameAr: 'إندونيسيا',
    code: 'ID',
    cities: [
      CityModel(name: 'Bandung',    nameAr: 'باندونغ',   lat: -6.9175,  lng: 107.6191),
      CityModel(name: 'Jakarta',    nameAr: 'جاكرتا',    lat: -6.2088,  lng: 106.8456),
      CityModel(name: 'Makassar',   nameAr: 'ماكاسار',   lat: -5.1477,  lng: 119.4327),
      CityModel(name: 'Medan',      nameAr: 'ميدان',     lat: 3.5952,   lng: 98.6722),
      CityModel(name: 'Surabaya',   nameAr: 'سورابايا',  lat: -7.2575,  lng: 112.7521),
      CityModel(name: 'Yogyakarta', nameAr: 'يوغياكارتا',lat: -7.7956,  lng: 110.3695),
    ],
  ),
  CountryModel(
    name: 'Iraq',
    nameAr: 'العراق',
    code: 'IQ',
    cities: [
      CityModel(name: 'Baghdad',  nameAr: 'بغداد',   lat: 33.3152, lng: 44.3661),
      CityModel(name: 'Basra',    nameAr: 'البصرة',  lat: 30.5085, lng: 47.7804),
      CityModel(name: 'Erbil',    nameAr: 'أربيل',   lat: 36.1901, lng: 44.0091),
      CityModel(name: 'Mosul',    nameAr: 'الموصل',  lat: 36.3350, lng: 43.1189),
      CityModel(name: 'Najaf',    nameAr: 'النجف',   lat: 31.9961, lng: 44.3351),
    ],
  ),
  CountryModel(
    name: 'Jordan',
    nameAr: 'الأردن',
    code: 'JO',
    cities: [
      CityModel(name: 'Aqaba',  nameAr: 'العقبة',  lat: 29.5321, lng: 35.0063),
      CityModel(name: 'Amman',  nameAr: 'عمّان',   lat: 31.9454, lng: 35.9284),
      CityModel(name: 'Irbid',  nameAr: 'إربد',    lat: 32.5556, lng: 35.8500),
      CityModel(name: 'Zarqa',  nameAr: 'الزرقاء', lat: 32.0630, lng: 36.0851),
    ],
  ),
  CountryModel(
    name: 'Kuwait',
    nameAr: 'الكويت',
    code: 'KW',
    cities: [
      CityModel(name: 'Farwaniya',   nameAr: 'الفروانية',  lat: 29.2776, lng: 47.9628),
      CityModel(name: 'Hawalli',     nameAr: 'حولي',       lat: 29.3366, lng: 48.0310),
      CityModel(name: 'Kuwait City', nameAr: 'مدينة الكويت',lat: 29.3759, lng: 47.9774),
      CityModel(name: 'Salmiya',     nameAr: 'السالمية',   lat: 29.3366, lng: 48.0768),
    ],
  ),
  CountryModel(
    name: 'Lebanon',
    nameAr: 'لبنان',
    code: 'LB',
    cities: [
      CityModel(name: 'Beirut',  nameAr: 'بيروت',  lat: 33.8938, lng: 35.5018),
      CityModel(name: 'Sidon',   nameAr: 'صيدا',   lat: 33.5619, lng: 35.3714),
      CityModel(name: 'Tripoli', nameAr: 'طرابلس', lat: 34.4367, lng: 35.8497),
      CityModel(name: 'Tyre',    nameAr: 'صور',    lat: 33.2704, lng: 35.2038),
    ],
  ),
  CountryModel(
    name: 'Libya',
    nameAr: 'ليبيا',
    code: 'LY',
    cities: [
      CityModel(name: 'Benghazi', nameAr: 'بنغازي',  lat: 32.1154, lng: 20.0685),
      CityModel(name: 'Misrata',  nameAr: 'مصراتة',  lat: 32.3754, lng: 15.0925),
      CityModel(name: 'Tripoli',  nameAr: 'طرابلس',  lat: 32.8872, lng: 13.1913),
    ],
  ),
  CountryModel(
    name: 'Malaysia',
    nameAr: 'ماليزيا',
    code: 'MY',
    cities: [
      CityModel(name: 'George Town',    nameAr: 'جورج تاون',    lat: 5.4164,  lng: 100.3327),
      CityModel(name: 'Johor Bahru',    nameAr: 'جوهور بهرو',   lat: 1.4927,  lng: 103.7414),
      CityModel(name: 'Kota Kinabalu',  nameAr: 'كوتا كينابالو',lat: 5.9749,  lng: 116.0724),
      CityModel(name: 'Kuala Lumpur',   nameAr: 'كوالالمبور',   lat: 3.1390,  lng: 101.6869),
    ],
  ),
  CountryModel(
    name: 'Morocco',
    nameAr: 'المغرب',
    code: 'MA',
    cities: [
      CityModel(name: 'Agadir',     nameAr: 'أغادير',    lat: 30.4202, lng: -9.5982),
      CityModel(name: 'Casablanca', nameAr: 'الدار البيضاء', lat: 33.5731, lng: -7.5898),
      CityModel(name: 'Fez',        nameAr: 'فاس',       lat: 34.0333, lng: -5.0000),
      CityModel(name: 'Marrakech',  nameAr: 'مراكش',     lat: 31.6295, lng: -7.9811),
      CityModel(name: 'Meknes',     nameAr: 'مكناس',     lat: 33.8935, lng: -5.5547),
      CityModel(name: 'Rabat',      nameAr: 'الرباط',    lat: 34.0209, lng: -6.8416),
      CityModel(name: 'Tangier',    nameAr: 'طنجة',      lat: 35.7595, lng: -5.8330),
    ],
  ),
  CountryModel(
    name: 'Netherlands',
    nameAr: 'هولندا',
    code: 'NL',
    cities: [
      CityModel(name: 'Amsterdam', nameAr: 'أمستردام', lat: 52.3676, lng: 4.9041),
      CityModel(name: 'Rotterdam', nameAr: 'روتردام',  lat: 51.9225, lng: 4.4792),
      CityModel(name: 'The Hague', nameAr: 'لاهاي',    lat: 52.0705, lng: 4.3007),
    ],
  ),
  CountryModel(
    name: 'Nigeria',
    nameAr: 'نيجيريا',
    code: 'NG',
    cities: [
      CityModel(name: 'Abuja',  nameAr: 'أبوجا',  lat: 9.0765,  lng: 7.3986),
      CityModel(name: 'Kano',   nameAr: 'كانو',   lat: 12.0022, lng: 8.5920),
      CityModel(name: 'Lagos',  nameAr: 'لاغوس',  lat: 6.5244,  lng: 3.3792),
      CityModel(name: 'Sokoto', nameAr: 'سوكوتو', lat: 13.0622, lng: 5.2339),
    ],
  ),
  CountryModel(
    name: 'Oman',
    nameAr: 'عُمان',
    code: 'OM',
    cities: [
      CityModel(name: 'Muscat',  nameAr: 'مسقط',   lat: 23.5880, lng: 58.3829),
      CityModel(name: 'Nizwa',   nameAr: 'نزوى',   lat: 22.9333, lng: 57.5333),
      CityModel(name: 'Salalah', nameAr: 'صلالة',  lat: 17.0151, lng: 54.0924),
      CityModel(name: 'Sohar',   nameAr: 'صحار',   lat: 24.3473, lng: 56.7455),
    ],
  ),
  CountryModel(
    name: 'Pakistan',
    nameAr: 'باكستان',
    code: 'PK',
    cities: [
      CityModel(name: 'Faisalabad', nameAr: 'فيصل آباد',  lat: 31.4187, lng: 73.0791),
      CityModel(name: 'Islamabad',  nameAr: 'إسلام آباد', lat: 33.6844, lng: 73.0479),
      CityModel(name: 'Karachi',    nameAr: 'كراتشي',     lat: 24.8607, lng: 67.0011),
      CityModel(name: 'Lahore',     nameAr: 'لاهور',      lat: 31.5204, lng: 74.3587),
      CityModel(name: 'Multan',     nameAr: 'ملتان',      lat: 30.1575, lng: 71.5249),
      CityModel(name: 'Peshawar',   nameAr: 'بيشاور',     lat: 34.0150, lng: 71.5805),
      CityModel(name: 'Rawalpindi', nameAr: 'راولبندي',   lat: 33.6007, lng: 73.0679),
    ],
  ),
  CountryModel(
    name: 'Palestine',
    nameAr: 'فلسطين',
    code: 'PS',
    cities: [
      CityModel(name: 'Gaza',      nameAr: 'غزة',      lat: 31.5017, lng: 34.4668),
      CityModel(name: 'Hebron',    nameAr: 'الخليل',   lat: 31.5320, lng: 35.0998),
      CityModel(name: 'Nablus',    nameAr: 'نابلس',    lat: 32.2211, lng: 35.2544),
      CityModel(name: 'Ramallah',  nameAr: 'رام الله', lat: 31.9038, lng: 35.2034),
    ],
  ),
  CountryModel(
    name: 'Qatar',
    nameAr: 'قطر',
    code: 'QA',
    cities: [
      CityModel(name: 'Al Rayyan', nameAr: 'الريان',  lat: 25.2922, lng: 51.4244),
      CityModel(name: 'Al Wakrah', nameAr: 'الوكرة',  lat: 25.1660, lng: 51.5984),
      CityModel(name: 'Doha',      nameAr: 'الدوحة',  lat: 25.2854, lng: 51.5310),
    ],
  ),
  CountryModel(
    name: 'Saudi Arabia',
    nameAr: 'المملكة العربية السعودية',
    code: 'SA',
    cities: [
      CityModel(name: 'Abha',    nameAr: 'أبها',    lat: 18.2164, lng: 42.5053),
      CityModel(name: 'Dammam',  nameAr: 'الدمام',  lat: 26.4207, lng: 50.0888),
      CityModel(name: 'Jeddah',  nameAr: 'جدة',     lat: 21.5433, lng: 39.1728),
      CityModel(name: 'Khobar',  nameAr: 'الخبر',   lat: 26.2172, lng: 50.1971),
      CityModel(name: 'Mecca',   nameAr: 'مكة المكرمة', lat: 21.3891, lng: 39.8579),
      CityModel(name: 'Medina',  nameAr: 'المدينة المنورة', lat: 24.5247, lng: 39.5692),
      CityModel(name: 'Riyadh',  nameAr: 'الرياض',  lat: 24.7136, lng: 46.6753),
      CityModel(name: 'Tabuk',   nameAr: 'تبوك',    lat: 28.3838, lng: 36.5550),
      CityModel(name: 'Taif',    nameAr: 'الطائف',  lat: 21.2703, lng: 40.4158),
    ],
  ),
  CountryModel(
    name: 'Senegal',
    nameAr: 'السنغال',
    code: 'SN',
    cities: [
      CityModel(name: 'Dakar',  nameAr: 'داكار',  lat: 14.7167, lng: -17.4677),
      CityModel(name: 'Touba',  nameAr: 'توبا',   lat: 14.8500, lng: -15.8833),
      CityModel(name: 'Thiès',  nameAr: 'تييس',   lat: 14.7833, lng: -16.9333),
    ],
  ),
  CountryModel(
    name: 'Sudan',
    nameAr: 'السودان',
    code: 'SD',
    cities: [
      CityModel(name: 'Khartoum',       nameAr: 'الخرطوم',        lat: 15.5007, lng: 32.5599),
      CityModel(name: 'Omdurman',       nameAr: 'أم درمان',       lat: 15.6471, lng: 32.4800),
      CityModel(name: 'Port Sudan',     nameAr: 'بورتسودان',      lat: 19.6158, lng: 37.2164),
    ],
  ),
  CountryModel(
    name: 'Syria',
    nameAr: 'سوريا',
    code: 'SY',
    cities: [
      CityModel(name: 'Aleppo',   nameAr: 'حلب',    lat: 36.2021, lng: 37.1343),
      CityModel(name: 'Damascus', nameAr: 'دمشق',   lat: 33.5138, lng: 36.2765),
      CityModel(name: 'Homs',     nameAr: 'حمص',    lat: 34.7324, lng: 36.7137),
      CityModel(name: 'Latakia',  nameAr: 'اللاذقية',lat: 35.5317, lng: 35.7913),
    ],
  ),
  CountryModel(
    name: 'Tunisia',
    nameAr: 'تونس',
    code: 'TN',
    cities: [
      CityModel(name: 'Kairouan', nameAr: 'القيروان', lat: 35.6772, lng: 10.0969),
      CityModel(name: 'Sfax',     nameAr: 'صفاقس',   lat: 34.7400, lng: 10.7600),
      CityModel(name: 'Sousse',   nameAr: 'سوسة',    lat: 35.8254, lng: 10.6360),
      CityModel(name: 'Tunis',    nameAr: 'تونس',    lat: 36.8190, lng: 10.1658),
    ],
  ),
  CountryModel(
    name: 'Turkey',
    nameAr: 'تركيا',
    code: 'TR',
    cities: [
      CityModel(name: 'Ankara',   nameAr: 'أنقرة',    lat: 39.9334, lng: 32.8597),
      CityModel(name: 'Antalya',  nameAr: 'أنطاليا',  lat: 36.8969, lng: 30.7133),
      CityModel(name: 'Bursa',    nameAr: 'بورصة',    lat: 40.1885, lng: 29.0610),
      CityModel(name: 'Istanbul', nameAr: 'إسطنبول',  lat: 41.0082, lng: 28.9784),
      CityModel(name: 'Izmir',    nameAr: 'إزمير',    lat: 38.4192, lng: 27.1287),
      CityModel(name: 'Konya',    nameAr: 'قونيا',    lat: 37.8714, lng: 32.4846),
    ],
  ),
  CountryModel(
    name: 'United Arab Emirates',
    nameAr: 'الإمارات العربية المتحدة',
    code: 'AE',
    cities: [
      CityModel(name: 'Abu Dhabi', nameAr: 'أبوظبي',  lat: 24.4539, lng: 54.3773),
      CityModel(name: 'Ajman',     nameAr: 'عجمان',   lat: 25.4052, lng: 55.5136),
      CityModel(name: 'Dubai',     nameAr: 'دبي',     lat: 25.2048, lng: 55.2708),
      CityModel(name: 'Sharjah',   nameAr: 'الشارقة', lat: 25.3463, lng: 55.4209),
    ],
  ),
  CountryModel(
    name: 'United Kingdom',
    nameAr: 'المملكة المتحدة',
    code: 'GB',
    cities: [
      CityModel(name: 'Birmingham', nameAr: 'برمنغهام',  lat: 52.4862, lng: -1.8904),
      CityModel(name: 'Bradford',   nameAr: 'برادفورد',  lat: 53.7960, lng: -1.7594),
      CityModel(name: 'Glasgow',    nameAr: 'غلاسكو',    lat: 55.8642, lng: -4.2518),
      CityModel(name: 'Leicester',  nameAr: 'ليستر',     lat: 52.6369, lng: -1.1398),
      CityModel(name: 'London',     nameAr: 'لندن',      lat: 51.5074, lng: -0.1278),
      CityModel(name: 'Manchester', nameAr: 'مانشستر',   lat: 53.4808, lng: -2.2426),
    ],
  ),
  CountryModel(
    name: 'United States',
    nameAr: 'الولايات المتحدة',
    code: 'US',
    cities: [
      CityModel(name: 'Chicago',      nameAr: 'شيكاغو',    lat: 41.8781,  lng: -87.6298),
      CityModel(name: 'Dearborn',     nameAr: 'ديربورن',   lat: 42.3223,  lng: -83.1763),
      CityModel(name: 'Houston',      nameAr: 'هيوستن',    lat: 29.7604,  lng: -95.3698),
      CityModel(name: 'Los Angeles',  nameAr: 'لوس أنجلوس',lat: 34.0522,  lng: -118.2437),
      CityModel(name: 'New York',     nameAr: 'نيويورك',   lat: 40.7128,  lng: -74.0060),
      CityModel(name: 'Washington DC',nameAr: 'واشنطن',    lat: 38.9072,  lng: -77.0369),
    ],
  ),
  CountryModel(
    name: 'Yemen',
    nameAr: 'اليمن',
    code: 'YE',
    cities: [
      CityModel(name: "Aden",    nameAr: 'عدن',     lat: 12.7794, lng: 45.0367),
      CityModel(name: "Sana'a",  nameAr: 'صنعاء',   lat: 15.3694, lng: 44.1910),
      CityModel(name: 'Taiz',    nameAr: 'تعز',     lat: 13.5771, lng: 44.0177),
    ],
  ),
];
