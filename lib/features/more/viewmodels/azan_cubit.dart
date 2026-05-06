import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'azan_state.dart';

class AzanCubit extends Cubit<AzanState> {
  static const _key = 'azan_enabled';

  AzanCubit() : super(const AzanState()) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final enabled = prefs.getBool(_key) ?? false;
    emit(AzanState(isAzanEnabled: enabled));
  }

  Future<void> toggleAzan() async {
    final newValue = !state.isAzanEnabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, newValue);
    emit(AzanState(isAzanEnabled: newValue));
  }
}