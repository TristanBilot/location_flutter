import 'package:logger/logger.dart' as log;

class Logger {
  Logger._internal();
  static final Logger _instance = Logger._internal();
  factory Logger() => _instance;

  final _logger = log.Logger(
    filter: null, // Use the default LogFilter (-> only log in debug mode)
    printer: log.PrefixPrinter(
      log.PrettyPrinter(
        colors: false,
        lineLength: 80,
        methodCount: 0,
      ),
    ), // Use the PrettyPrinter to format and print log
    output: null, // Use the default LogOutput (-> send everything to console)
  );

  void i(dynamic message) {
    _logger.i(message);
  }

  void w(dynamic message) {
    _logger.w(message);
  }

  void e(dynamic message) {
    _logger.e(message);
  }

  void v(dynamic message) {
    _logger.v(message);
  }
}
