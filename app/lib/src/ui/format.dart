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

/// « 4 min de lecture ».
String formatReadingTime(int minutes) =>
    '$minutes min de lecture';
