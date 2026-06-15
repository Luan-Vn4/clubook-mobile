import 'package:logger/logger.dart';

// Re-export so callers can declare typed loggers (e.g. `final Logger log`)
// using only this import, without importing the logger package directly.
export 'package:logger/logger.dart' show Logger;

/// Centralized logger configuration for the application.
///
/// Provides a single source of truth for logger setup, ensuring consistent
/// one-line log output via [SimplePrinter] across all layers (infra, ui).
///
/// Usage:
/// ```dart
/// final logger = AppLogger.create();
/// logger.d('Token expirado.');
/// ```
class AppLogger {
  AppLogger._();

  /// Creates a configured [Logger] instance.
  ///
  /// Uses [SimplePrinter] for concise one-line output (e.g. `[D] Message`)
  /// instead of the default [PrettyPrinter] which emits multi-line logs
  /// with box-drawing characters and stack traces.
  ///
  /// [ProductionFilter] ensures logs respect the configured level in both
  /// debug and release builds.
  static Logger create() {
    return Logger(
      printer: SimplePrinter(),
      filter: ProductionFilter(),
    );
  }
}
