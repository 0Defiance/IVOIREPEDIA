const List<String> _months = [
  'janvier',
  'février',
  'mars',
  'avril',
  'mai',
  'juin',
  'juillet',
  'août',
  'septembre',
  'octobre',
  'novembre',
  'décembre',
];

/// « 3 novembre 2026 » — format long français, sans dépendance de locale.
String formatDate(DateTime? date) {
  if (date == null) {
    return '';
  }

  return '${date.day} ${_months[date.month - 1]} ${date.year}';
}

/// « 6 321 017 » — séparateur de milliers insécable, sans dépendre d'une
/// locale installée dans le navigateur.
String formatNumber(int value) {
  final digits = value.abs().toString();
  final buffer = StringBuffer();

  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) {
      buffer.write('\u00A0');
    }
    buffer.write(digits[i]);
  }

  return '${value < 0 ? '−' : ''}$buffer';
}

/// « 4 min de lecture ».
String formatReadingTime(int minutes) =>
    '$minutes min de lecture';
