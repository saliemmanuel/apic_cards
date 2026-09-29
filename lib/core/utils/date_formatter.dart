/// Utilitaire pur Dart pour le formatage et le parsing des dates en jj/mm/aaaa.
class DateFormatter {
  DateFormatter._();

  /// Formate un [DateTime] en chaîne 'jj/mm/aaaa'.
  static String format(DateTime? date) {
    if (date == null) return '';
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString().padLeft(4, '0');
    return '$day/$month/$year';
  }

  /// Parse une chaîne 'jj/mm/aaaa' en [DateTime], retourne null si invalide.
  static DateTime? parse(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final parts = value.trim().split('/');
    if (parts.length != 3) return null;
    final day = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    final year = int.tryParse(parts[2]);
    if (day == null || month == null || year == null) return null;
    try {
      return DateTime(year, month, day);
    } catch (_) {
      return null;
    }
  }
}
