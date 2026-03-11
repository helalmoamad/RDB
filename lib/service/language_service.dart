import 'package:flutter/cupertino.dart';
import 'package:easy_localization/easy_localization.dart';

enum LangCode { ar, en, tr, ku }

List<Locale> supportedLocal = [
  localMap[LangCode.ar]!,
  localMap[LangCode.en]!,
  localMap[LangCode.tr]!,
  localMap[LangCode.ku]!,
];

final Locale defaultLocal = localMap[LangCode.en]!;

final localMap = {
  LangCode.en: const Locale('en', 'US'),
  LangCode.tr: const Locale('tr', 'TR'),
  LangCode.ar: const Locale('ar', 'SY'),
  // Kurdish (Sorani) - Arabic script, Iraq
  LangCode.ku: const Locale('ku', 'IQ'),
};

final mpaLanguageCodeToLocale = {
  LangCode.en.name: const Locale('en', 'US'),
  LangCode.ar.name: const Locale('ar', 'SY'),
  LangCode.tr.name: const Locale('tr', 'TR'),
  LangCode.ku.name: const Locale('ku', 'IQ'),
  // Map common aliases to Sorani locale as well
};

final languageNameAndLanguageCode = <String, LangCode>{
  'English': LangCode.en,
  'Arabic': LangCode.ar,
  'Turkish': LangCode.tr,
  'Kurdish (Sorani)': LangCode.ku,
};

class LanguageService {
  static late Locale currentLanguage;
  static String languageCode = 'en';
  static late bool rtl;
  static late bool isKurdish;

  final BuildContext context;
  static LanguageService? _instance;

  LanguageService._singleton(this.context) {
    currentLanguage = _currentLanguage;
    languageCode = _languageCodeNormalized;
    rtl = _rtl;
    isKurdish = _isKurdish;
  }

  factory LanguageService(BuildContext context) {
    if (_instance != null) {
      if (context.locale.languageCode != languageCode) {
        return LanguageService._singleton(context);
      }
      return _instance!;
    }
    return LanguageService._singleton(context);
  }

  Locale get _currentLanguage => context.locale;

  String get _languageCode => _currentLanguage.languageCode;

  // For historical checks across the app that compare to "ar",
  // normalize Kurdish Sorani to behave like Arabic (RTL/layout tweaks)
  String get _languageCodeNormalized {
    final String code = _languageCode;
    if (code == 'ku') return 'ar';
    return code;
  }

  bool get _isKurdish {
    return _currentLanguage.languageCode == 'ku';
  }

  bool get _rtl {
    final String code = _currentLanguage.languageCode;
    return code == 'ar' || code == 'ku';
  }
}
