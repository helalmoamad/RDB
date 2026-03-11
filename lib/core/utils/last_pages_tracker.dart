import 'package:flutter/material.dart';

class LastPagesTracker {
  static final List<String> _lastPages = [];

  static void push(String pageName) {
    if (_lastPages.isNotEmpty) {
      if (_lastPages.last != pageName) {
        _lastPages.add(pageName);
        if (_lastPages.length > 5) {
          _lastPages.removeAt(0);
        }
      }
    } else {
      _lastPages.add(pageName);
    }
  }

  static List<String> get lastPages => List.unmodifiable(_lastPages);

  static void sendErrorToBlocAndLog(FlutterErrorDetails error) {
    /* GetIt.I<PrefsRepository>().saveRequestsData(
        null, null, null, null, null, null, null,
        error: error.toString());

    GetIt.I<PrefsRepository>().saveRequestsData(
        null, null, null, null, null, null, null,
        error: error.toString());
    debugPrint('error $error');
    GetIt.I<HomeBloc>().add(
      SendErrorToMobileErrorLogEvent(
        errorExption:
            'Type:${error.exception.runtimeType.toString()} ${error.exceptionAsString().toString()}',
        errorPath: error.stack.toString().split('#2').first,
        urlBackend: "Front Error",
        messageFromeBackend: "Front Error",
        lastForPageHasBeenVisited: LastPagesTracker.lastPages.join(' > '),
      ),
    );*/
    // يمكنك هنا أيضًا إضافة أي لوج إضافي أو تخزين محلي إذا رغبت
  }
}
