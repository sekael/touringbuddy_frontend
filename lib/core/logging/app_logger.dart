// lib/core/logging/app_logger.dart
import 'package:logger/logger.dart';
import 'package:touringbuddy_frontend/core/logging/log_printer.dart';

class AppLogger {
  AppLogger._internal();

  static final AppLogger instance = AppLogger._internal();

  final Logger _logger = Logger(
    printer: SingleLinePrinter(colors: true, printTime: true),
    // printer: PrettyPrinter(
    //   methodCount: 0, // no method stacktrace by default
    //   errorMethodCount: 8, // stacktrace depth for errors
    //   lineLength: 200,
    //   colors: true,
    //   printEmojis: false,
    //   dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
    //   noBoxingByDefault: true,
    // ),
  );

  void d(String message) => _log(LogLevel.debug, message);
  void i(String message) => _log(LogLevel.info, message);
  void w(String message) => _log(LogLevel.warning, message);
  void e(String message, [Object? error, StackTrace? st]) =>
      _log(LogLevel.error, message, error, st);

  void _log(
    LogLevel level,
    String message, [
    Object? error,
    StackTrace? stackTrace,
  ]) {
    final logLine = _formatMessage(message);
    switch (level) {
      case LogLevel.debug:
        _logger.d(logLine, error: error, stackTrace: stackTrace);
        break;
      case LogLevel.info:
        _logger.i(logLine, error: error, stackTrace: stackTrace);
        break;
      case LogLevel.warning:
        _logger.w(logLine, error: error, stackTrace: stackTrace);
        break;
      case LogLevel.error:
        _logger.e(logLine, error: error, stackTrace: stackTrace);
        break;
    }
  }

  String _formatMessage(String message) {
    // simple hook to inject class/method tags if you want
    return message;
  }
}

enum LogLevel { debug, info, warning, error }

// convenience top-level
final logger = AppLogger.instance;
