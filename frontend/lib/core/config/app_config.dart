/// Runtime configuration for the app.
///
/// The TTS service base URL is read from the compile-time define
/// `--dart-define=API_BASE_URL=...`, defaulting to the local FastAPI service.
/// Kept dependency-free: no dotenv, just [String.fromEnvironment].
abstract final class AppConfig {
  AppConfig._();

  /// Base origin of the TTS service (FastAPI), e.g. `http://127.0.0.1:8000`.
  ///
  /// Override at build/run time:
  /// `flutter run --dart-define=API_BASE_URL=http://192.168.1.5:8000`
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://127.0.0.1:8000',
  );
}