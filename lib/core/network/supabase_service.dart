import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static const String baseUrl = 'https://xndpsfzvotlegrtnfanf.supabase.co';
  static const String apiKey = "sb_publishable_2dAVgqQoQuT7iy5HcVY-XA__ygO3nwG";

  static init() async {
    await Supabase.initialize(
      url: baseUrl,
      anonKey: apiKey,
    );
  }
}
