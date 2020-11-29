import 'package:location_project/repositories/user/time_measurable.dart';
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

  void logUserInfo(
    String id, {
    TimeMeasurable infos,
    TimeMeasurable pictures,
    TimeMeasurable blocks,
    TimeMeasurable views,
    TimeMeasurable likes,
  }) {
    String str = '=> Fetch $id';
    int sum = 0;
    if (infos != null) {
      str += '\ninfo fetching: \t${infos.timeToFetch}ms';
      sum += infos.timeToFetch;
    }
    if (blocks != null) {
      str += '\nblock fetching: \t${blocks.timeToFetch}ms';
      sum += blocks.timeToFetch;
    }
    if (views != null) {
      str += '\nviews fetching: \t${views.timeToFetch}ms';
      sum += views.timeToFetch;
    }
    if (pictures != null) {
      str += '\npictures fetching: \t${pictures.timeToFetch}ms';
      sum += pictures.timeToFetch;
    }
    if (likes != null) {
      str += '\nlikes fetching: \t${likes.timeToFetch}ms';
      sum += likes.timeToFetch;
    }
    str += '\t=> ${sum}ms';
    Logger().v(str);
  }
}
