/// Result of an operation that can fail.
///
/// Domain and application code represent failures explicitly instead of
/// throwing raw exceptions through the architecture. [Ok] carries a value,
/// [Err] carries a [Failure].
library;

import 'package:navigation_voice_generator/core/error/failures.dart';

sealed class Result<T> {
  const Result();

  bool get isOk => this is Ok<T>;
  bool get isErr => this is Err<T>;
}

final class Ok<T> extends Result<T> {
  const Ok(this.value);

  final T value;
}

final class Err<T> extends Result<T> {
  const Err(this.failure);

  final Failure failure;
}
