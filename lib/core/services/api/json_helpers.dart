T enumByNameOr<T extends Enum>(
  List<T> values,
  String? name,
  T fallback,
) {
  if (name == null) {
    return fallback;
  }
  for (final T value in values) {
    if (value.name == name) {
      return value;
    }
  }
  return fallback;
}

DateTime parseDateTime(dynamic input, {DateTime? fallback}) {
  if (input is String) {
    return DateTime.tryParse(input) ?? (fallback ?? DateTime.now());
  }
  if (input is int) {
    return DateTime.fromMillisecondsSinceEpoch(input);
  }
  return fallback ?? DateTime.now();
}

double parseDouble(dynamic input, {double fallback = 0}) {
  if (input is num) {
    return input.toDouble();
  }
  if (input is String) {
    return double.tryParse(input) ?? fallback;
  }
  return fallback;
}

int parseInt(dynamic input, {int fallback = 0}) {
  if (input is int) {
    return input;
  }
  if (input is num) {
    return input.toInt();
  }
  if (input is String) {
    return int.tryParse(input) ?? fallback;
  }
  return fallback;
}

List<String> parseStringList(dynamic input) {
  if (input is List) {
    return input.whereType<Object>().map((Object item) => item.toString()).toList();
  }
  return <String>[];
}
