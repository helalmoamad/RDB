import 'package:easy_localization/easy_localization.dart';

import '../../../service/language_service.dart';

extension DateFormatter on DateTime {
  String get nameDayAndNumberOfMonth =>
      DateFormat('MMM M', defaultLocal.languageCode).format(this);
}
