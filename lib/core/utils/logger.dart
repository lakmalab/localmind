class Logger {
  static void log(String message, {String? tag}) {
    final timestamp = DateTime.now().toString().substring(11, 19);
    final logMessage = tag != null
        ? '$timestamp [$tag] - $message'
        : '$timestamp - $message';
    print(logMessage);
  }

  static void error(String message, {Object? error, StackTrace? stackTrace}) {
    log('ERROR: $message', tag: 'ERROR');
    if (error != null) print('Error details: $error');
    if (stackTrace != null) print('Stack trace: $stackTrace');
  }
}