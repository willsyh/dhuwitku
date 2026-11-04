import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Combines several [AsyncValue]s: error wins, then loading, then data.
AsyncValue<R> combineAsync<R>(
  List<AsyncValue<Object?>> values,
  R Function() build,
) {
  for (final v in values) {
    if (v.hasError && !v.hasValue) {
      return AsyncValue.error(v.error!, v.stackTrace ?? StackTrace.current);
    }
  }
  if (values.any((v) => !v.hasValue)) return const AsyncValue.loading();
  try {
    return AsyncValue.data(build());
  } catch (e, st) {
    return AsyncValue.error(e, st);
  }
}
