import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// Error reporting seam.
///
/// D6 (monitoring vendor) is not yet decided, so no third-party SDK is
/// bundled and nothing leaves the browser. The seam captures framework and
/// zone errors into a bounded in-memory ring buffer (and the console outside
/// production). Plugging a vendor later means implementing [ErrorSink] once.
abstract interface class ErrorSink {
  void report(Object error, StackTrace? stack, {required String origin});
}

class ConsoleErrorSink implements ErrorSink {
  const ConsoleErrorSink();

  @override
  void report(Object error, StackTrace? stack, {required String origin}) {
    debugPrint('PAL_EYES_ERROR[$origin] $error');
  }
}

class ErrorReporterConfig {
  const ErrorReporterConfig({required this.mode});

  const ErrorReporterConfig.fromCompileTime()
    : mode = const String.fromEnvironment(
        'PAL_EYES_ERROR_REPORTING',
        defaultValue: 'buffer',
      );

  /// `buffer` (default) or `console`. Any vendor mode is refused until D6.
  final String mode;
}

class CapturedError {
  const CapturedError(this.origin, this.message, this.at);

  final String origin;
  final String message;
  final DateTime at;
}

abstract final class ErrorReporting {
  static const int capacity = 50;
  static final ListQueue<CapturedError> _buffer = ListQueue<CapturedError>();
  static ErrorSink? _sink;

  static List<CapturedError> get recent =>
      List<CapturedError>.unmodifiable(_buffer);

  static void capture(Object error, StackTrace? stack, String origin) {
    if (_buffer.length >= capacity) _buffer.removeFirst();
    _buffer.addLast(
      CapturedError(origin, error.toString(), DateTime.now().toUtc()),
    );
    _sink?.report(error, stack, origin: origin);
  }

  @visibleForTesting
  static void reset() {
    _buffer.clear();
    _sink = null;
  }

  static void _configure(ErrorReporterConfig config) {
    _sink = config.mode == 'console' && !kReleaseMode
        ? const ConsoleErrorSink()
        : null;
  }
}

void installErrorReporting(ErrorReporterConfig config) {
  ErrorReporting._configure(config);
  final previous = FlutterError.onError;
  FlutterError.onError = (details) {
    ErrorReporting.capture(details.exception, details.stack, 'flutter');
    previous?.call(details);
  };
  final dispatcher = WidgetsBinding.instance.platformDispatcher;
  final previousPlatform = dispatcher.onError;
  dispatcher.onError = (error, stack) {
    ErrorReporting.capture(error, stack, 'platform');
    return previousPlatform?.call(error, stack) ?? false;
  };
}
