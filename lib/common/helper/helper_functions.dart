import 'dart:io';
import 'dart:math';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:easy_localization/easy_localization.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:rdb/common/constant/countries.dart';
import 'package:rdb/core/domin/repositories/prefs_repository.dart';
import 'package:rdb/features/app/my_text_widget.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../generated/locale_keys.g.dart';
import '../../service/language_service.dart';

final PrefsRepository _prefsRepository = GetIt.I<PrefsRepository>();

class HelperFunctions {
  static changeAppStatus(ThemeMode theme) {
    final color = theme == ThemeMode.dark
        ? const Color(0xFF191C1D)
        : const Color(0xFFFBFDFD);
    final brightness = theme == ThemeMode.light
        ? Brightness.dark
        : Brightness.light;

    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: color,
        statusBarIconBrightness: brightness,
      ),
    );
  }

  static Future<String> changeSvgColor(String svgPath, String newColor) async {
    String svgCode = await rootBundle.loadString(svgPath);

    svgCode = svgCode.replaceAll("CC3333", newColor.toUpperCase());
    return svgCode;
  }

  static Future<bool> urlLauncherApplication(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      return await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
        webViewConfiguration: const WebViewConfiguration(
          enableDomStorage: false,
          enableJavaScript: false,
        ),
      );
    } else {
      throw Exception('Unable to launch url');
    }
  }

  static Future<bool> urlLauncherBrowser(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      return await launchUrl(uri, mode: LaunchMode.inAppWebView);
    } else {
      throw Exception('Unable to launch url');
    }
  }

  static String replaceDashAfterFirst(String input) {
    int firstDashIndex = input.indexOf('-');
    if (firstDashIndex == -1) {
      // لا يوجد "-"
      return input;
    }

    // البحث عن الظهور الثاني للمحرف "-"
    int secondDashIndex = input.indexOf('-', firstDashIndex + 1);
    if (secondDashIndex == -1) {
      // لا يوجد إلا "-" واحد
      return input;
    }

    // استبدال كل "-" بعد الظهور الأول بـ "_"
    StringBuffer result = StringBuffer();
    bool replacedSecondAndAfter = false;

    for (int i = 0; i < input.length; i++) {
      if (input[i] == '-') {
        if (!replacedSecondAndAfter && i > firstDashIndex) {
          replacedSecondAndAfter = true;
        }
        if (replacedSecondAndAfter) {
          result.write('_');
        } else {
          result.write('-');
        }
      } else {
        result.write(input[i]);
      }
    }

    return result.toString();
  }

  static Locale getInitLocale() {
    // ignore: deprecated_member_use
    final devicelang = WidgetsBinding.instance.window.locale.languageCode;
    return _prefsRepository.language == null
        ? mpaLanguageCodeToLocale[devicelang] ?? defaultLocal
        : mpaLanguageCodeToLocale[_prefsRepository.language] ?? defaultLocal;
  }

  static Country getDefaultCountry() {
    // ignore: deprecated_member_use
    final deviceCountryCode = WidgetsBinding.instance.window.locale.countryCode;
    return countries.singleWhere(
      (element) => element.code == deviceCountryCode,
      orElse: () => defaultCountry,
    );
  }

  static Route createRoute(Widget child) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, 1.0);
        const end = Offset.zero;
        const curve = Curves.ease;

        var tween = Tween(
          begin: begin,
          end: end,
        ).chain(CurveTween(curve: curve));

        return SlideTransition(position: animation.drive(tween), child: child);
      },
    );
  }

  static DateTime parseToUtc(String dateTimeString) {
    // نقسم النص إلى تاريخ ووقت
    final parts = dateTimeString.split(' ');
    if (parts.length != 2) {
      throw const FormatException('صيغة التاريخ غير صحيحة');
    }

    final dateParts = parts[0].split('-');
    final timeParts = parts[1].split(':');

    if (dateParts.length != 3 || timeParts.length != 3) {
      throw const FormatException('صيغة التاريخ أو الوقت غير صحيحة');
    }

    return DateTime.utc(
      int.parse(dateParts[0]), // السنة
      int.parse(dateParts[1]), // الشهر
      int.parse(dateParts[2]), // اليوم
      int.parse(timeParts[0]), // الساعة
      int.parse(timeParts[1]), // الدقيقة
      int.parse(timeParts[2]), // الثانية
    );
  }

  static String getTheFirstTwoLettersOfName(String name) {
    return name.split(' ').length == 2
        ? name.split(' ')[0][0] + name.split(' ')[1][0]
        : name.split(' ').first.length > 1
        ? (name.split(' ')[0][0] + name.split(' ')[0][1])
        : name.split(' ').first;
  }

  static String getDatesInFormat(DateTime date) {
    String formattedDate = DateFormat('MMMMd').format(date.toLocal());
    return formattedDate;
  }

  static String getDateInFormatForShippingDays(int shippingDays) {
    DateTime date = DateTime.now().add(Duration(days: shippingDays));
    String formattedDate = DateFormat('EEEE, d MMM yy', 'ar').format(date);

    return formattedDate;
  }

  static String gettimesInFormat(DateTime time) {
    String formattedDate = DateFormat("jm").format(time.toLocal());
    return formattedDate;
  }

  static String replaceArabicNumber(String input) {
    const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const arabic = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];

    for (int i = 0; i < english.length; i++) {
      input = input.replaceAll(arabic[i], english[i]);
    }
    return input;
  }

  static String getZonedDateInFormat(DateTime date) {
    String formattedTime = DateFormat.Hm().format(date.toLocal());
    return formattedTime;
  }

  static String getDateInFormat(DateTime date) {
    String formattedTime = DateFormat.Hm().format(date);
    return formattedTime;
  }

  static DateTime getZonedDate(DateTime date) {
    return date.toLocal();
  }

  static DateTime getZonedDateWithoutUtcForm(String date) {
    return parseToUtc(date).toLocal();
  }

  static String getTimeInFormat(Duration duration) {
    String? hours = duration.inHours > 0
        ? twoDigits(duration.inHours.remainder(60))
        : null;
    String minutes = twoDigits(duration.inMinutes.remainder(60));
    String seconds = twoDigits(duration.inSeconds.remainder(60));
    return '${hours ?? ''}$minutes:$seconds';
  }

  static String twoDigits(int n) {
    return n.toString().padLeft(2, '0');
  }

  static Future<String?> getDeviceId() async {
    var deviceInfo = DeviceInfoPlugin();
    if (Platform.isIOS) {
      var iosDeviceInfo = await deviceInfo.iosInfo;
      return iosDeviceInfo.identifierForVendor;
    } else if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      return '${androidInfo.id}_${androidInfo.model}';
    }
    return 'other_os';
  }

  static showVersionDialog(context) async {
    await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        String title = LocaleKeys.new_update_available.tr();
        String message = LocaleKeys.newer_version_available_message.tr();
        String btnLabel1 = LocaleKeys.update_now.tr();
        String btnLabel2 = LocaleKeys.not_now.tr();
        // ignore: deprecated_member_use
        return WillPopScope(
          onWillPop: () => Future.value(true),
          child: Platform.isIOS
              ? CupertinoAlertDialog(
                  title: Column(
                    children: [
                      const Icon(
                        Icons.system_update_rounded,
                        size: 40,
                        color: Color(0xFF007AFF),
                      ),
                      const SizedBox(height: 12),
                      MyTextWidget(
                        title,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1D1D1F),
                        ),
                      ),
                    ],
                  ),
                  content: Column(
                    children: [
                      MyTextWidget(
                        message,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF6E6E73),
                          height: 1.3,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                  actions: <Widget>[
                    Row(
                      children: [
                        Expanded(
                          child: CupertinoButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text(
                              btnLabel2,
                              style: const TextStyle(
                                color: Color(0xFF6E6E73),
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: CupertinoButton.filled(
                            onPressed: () {
                              Navigator.pop(context); // إغلاق الحوار
                              _openWhatsAppGroup(); // فتح الواتساب
                            },
                            child: Text(
                              btnLabel1,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                )
              : AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  title: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          // ignore: deprecated_member_use
                          color: const Color(0xFF007AFF).withOpacity(0.12),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.system_update_rounded,
                          size: 40,
                          color: Color(0xFF007AFF),
                        ),
                      ),
                      const SizedBox(height: 12),
                      MyTextWidget(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
                          color: Color(0xFF1D1D1F),
                        ),
                      ),
                    ],
                  ),
                  content: Column(
                    children: [
                      MyTextWidget(
                        message,
                        style: const TextStyle(
                          color: Color(0xFF6E6E73),
                          height: 1.4,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                    ],
                  ),
                  actions: <Widget>[
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () => Navigator.pop(context),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              btnLabel2,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF6E6E73),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context); // إغلاق الحوار
                              _openWhatsAppGroup(); // فتح الواتساب
                            },
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              backgroundColor: const Color(0xFF007AFF),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              elevation: 2,
                            ),
                            child: Text(
                              btnLabel1,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
        );
      },
    );
  }
  /*static _getFileFromGoogleDrive() {
    urlLauncherBrowser(
        'https://drive.google.com/file/d/1im1-7Bmx5Qi9cTsVIvGnZIvNY7vSKQLj/view?usp=drivesdk');
  }*/

  static _openWhatsAppGroup() async {
    try {
      // رابط مجموعة واتساب - يمكنك تغييره برابط مجموعة الواتساب الخاصة بك
      String whatsappGroupUrl =
          'https://chat.whatsapp.com/JVCvHFxKQBM9fQiTAPOsyf?mode=ac_t';

      // محاولة فتح تطبيق واتساب مباشرة مع رابط المجموعة
      // هذا سيفتح المجموعة مباشرة في التطبيق

      bool launched = await urlLauncherApplication(whatsappGroupUrl);

      // إذا فشل فتح التطبيق، افتح المتصفح
      if (!launched) {
        await urlLauncherBrowser(whatsappGroupUrl);
      }
    } catch (e) {
      // في حالة حدوث خطأ، افتح المتصفح مباشرة
      String whatsappGroupUrl =
          'https://chat.whatsapp.com/JVCvHFxKQBM9fQiTAPOsyf?mode=ac_t';
      await urlLauncherBrowser(whatsappGroupUrl);
    }
  }

  static slidingNavigation(BuildContext context, Widget page) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => page,
        transitionsBuilder: (_, __, ___, child) => child, // بدون أي حركة
        transitionDuration: Duration.zero, // انتقال فوري
        reverseTransitionDuration: Duration.zero, // عودة فورية
      ),
    );
    // Navigator.of(context).push(MaterialPageRoute(builder: (context) => page));
    /*  Navigator.of(context).push(new PageRouteBuilder(
      opaque: false,
      transitionDuration: Duration(milliseconds: milliseconds),
      pageBuilder: (BuildContext context, _, __) {
        return DragToPop(child: page);
      },*/
    /*transitionsBuilder: (_, Animation<double> animation, __, Widget child) {
          return new SlideTransition(
            child: child,
            position: new Tween<Offset>(
              begin: const Offset(1, 0), //// navigation from right
              end: Offset.zero,
            ).animate(animation),
          );
        }*/
    // ));
  }

  static double truncateToDecimalPlaces(double number, int decimalPlaces) {
    double mod = pow(10.0, decimalPlaces).toDouble();
    return (number * mod).ceilToDouble() / mod;
  }

  // }
  /*else if (iso == 'LB') {
        if (number >= 1e4 && number < 1e6) {
          String result = (((number + 9999) ~/ 10000) * 10).toStringAsFixed(
              GetIt.I<HomeBloc>().state.startingSetting?.decimalPointSettings ??
                  2);
          ;

          return '$result$thousand';
        } else if (number == 0) {
          return '0.0';
        } else if (number < 1e4) {
          return '10$thousand';
        } else {
          String result = (((((number + 9999) ~/ 10000) * 10)) / 1000)
              .toStringAsFixed((GetIt.I<HomeBloc>()
                          .state
                          .startingSetting
                          ?.decimalPointSettings ??
                      2) +
                  3);
          if ((result.lastIndexOf(RegExp(r'.000'))) != -1) {
            result = result.substring(0, (result.lastIndexOf(RegExp(r'.000'))));
          }
          return '$result$million';
        }
      } else {
        String result = number.toStringAsFixed(
            GetIt.I<HomeBloc>().state.startingSetting?.decimalPointSettings ??
                2);

        return result;
      }*/
  //}
  /*else {
      String result = number.toStringAsFixed(
          GetIt.I<HomeBloc>().state.startingSetting?.decimalPointSettings ?? 2);

      return result;
    }*/
}
