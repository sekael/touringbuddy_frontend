// lib/core/logging/single_line_printer.dart
import 'package:logger/logger.dart';

class SingleLinePrinter extends LogPrinter {
  SingleLinePrinter({this.colors = true, this.printTime = true});

  final bool colors;
  final bool printTime;

  @override
  List<String> log(LogEvent event) {
    final buffer = StringBuffer();

    // [timestamp]
    if (printTime) {
      final ts = event.time.toIso8601String(); // or customize if you like
      buffer.write('[$ts] ');
    }

    // [LEVEL]
    final levelLabel = event.level.name.toUpperCase();
    String levelPart = '[$levelLabel]';

    if (colors) {
      final color = SimplePrinter.levelColors[event.level];
      if (color != null) {
        levelPart = color(levelPart);
      }
    }

    buffer.write('$levelPart ');

    // message (we'll put [Class - method] into the message itself)
    buffer.write(event.message);

    // optional: include error + stack trace for error logs
    if (event.error != null) {
      buffer.write('  ERROR: ${event.error}');
    }
    if (event.stackTrace != null) {
      buffer.write('\n${event.stackTrace}');
    }

    return [buffer.toString()];
  }
}
