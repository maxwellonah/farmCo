Stream<T> pollingStream<T>(
  Future<T> Function() loader, {
  Duration interval = const Duration(seconds: 5),
}) async* {
  while (true) {
    try {
      yield await loader();
    } catch (_) {
      // Keep stream alive for transient API errors; consumers can render last value.
    }
    await Future<void>.delayed(interval);
  }
}
