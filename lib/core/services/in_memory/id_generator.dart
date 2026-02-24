int _counter = 0;

String generateId(String prefix) {
  _counter += 1;
  final int stamp = DateTime.now().microsecondsSinceEpoch;
  return '$prefix-$stamp-$_counter';
}
