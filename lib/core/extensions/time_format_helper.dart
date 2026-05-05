class TimeFormatHelper {
  static String format(String hhmm, bool use24Hour) {
    final parts = hhmm.split(':');
    if (parts.length < 2) return hhmm;
    final h = int.tryParse(parts[0]) ?? 0;
    final m = parts[1];
    if (use24Hour) {
      return '${h.toString().padLeft(2, '0')}:$m';
    }
    final period = h < 12 ? 'AM' : 'PM';
    final h12 = h == 0 ? 12 : (h > 12 ? h - 12 : h);
    return '$h12:$m $period';
  }
}
