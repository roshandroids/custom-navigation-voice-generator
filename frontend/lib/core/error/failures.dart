/// Base class for all application failures.
///
/// Presentation maps failures to user-facing messages; raw exceptions and
/// stack traces are never shown to the user.
sealed class Failure {
  const Failure(this.message);

  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

final class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

final class NotFoundFailure extends Failure {
  const NotFoundFailure(super.message);
}

final class TtsGenerationFailure extends Failure {
  const TtsGenerationFailure(super.message);
}

final class SuggestionFailure extends Failure {
  const SuggestionFailure(super.message);
}

final class RepositoryFailure extends Failure {
  const RepositoryFailure(super.message);
}

final class InvalidTransitionFailure extends Failure {
  const InvalidTransitionFailure(super.message);
}

final class UnexpectedFailure extends Failure {
  const UnexpectedFailure(super.message);
}
