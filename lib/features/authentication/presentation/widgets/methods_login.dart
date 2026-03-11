import 'package:dotted_border/dotted_border.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_it/get_it.dart';
import 'package:rdb/common/test_utils/test_var.dart';
import 'package:rdb/core/utils/extensions/build_context.dart';
import 'package:rdb/core/utils/last_pages_tracker.dart';
import 'package:rdb/generated/locale_keys.g.dart';
import 'package:rdb/theme/typography.dart';
import 'dart:ui' as ui;
import '../../../../common/test_utils/widgets_keys.dart';
import '../../../../core/domin/repositories/prefs_repository.dart';
import '../../../../core/utils/responsive_padding.dart';
import '../../../app/my_text_widget.dart';

class MethodsLogin extends StatefulWidget {
  const MethodsLogin({
    required this.goToAddPhone,
    required this.goToScanQrCode,
    super.key,
  });
  final void Function() goToAddPhone;
  final void Function() goToScanQrCode;

  @override
  State<MethodsLogin> createState() => _MethodsLoginState();
}

class _MethodsLoginState extends State<MethodsLogin> {
  //  bool _eventLogged = false;
  /*@override
  void didChangeDependencies() async {
    if (!_eventLogged) {
      FirebaseAnalyticsService.logEventForSession(
        eventName: AnalyticsEventsConst.SCREEN_VIEW,
        executedEventName: AuthScreenConst.SELECT_AUTHINTCTION_METHOD_SCREEN,
        extraParams: {
          'screen_name': AuthScreenConst.SELECT_AUTHINTCTION_METHOD_SCREEN,
          'screen_path': '',
          'platform': GlobalPlatform.MOBILE,
        },
      );
      _eventLogged = true;
    }

    super.didChangeDependencies();
  }*/

  final ValueNotifier<int> clickButton = ValueNotifier(-1);

  final PrefsRepository prefsRepository = GetIt.I<PrefsRepository>();

  @override
  Widget build(BuildContext context) {
    FlutterError.onError = (FlutterErrorDetails error) {
      LastPagesTracker.sendErrorToBlocAndLog(error);
      FlutterError.dumpErrorToConsole(error);
    };
    return Directionality(
      textDirection: ui.TextDirection.ltr,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Padding(
            padding: HWEdgeInsets.symmetric(horizontal: 30.0),
            child: MyTextWidget(
              LocaleKeys.welcome_page_description.tr(),
              textAlign: TextAlign.center,
              style: context.textTheme.titleLarge?.lq.copyWith(
                color: const Color(0xff5D5C5D),
                letterSpacing: 0.14,
                height: 1.3,
              ),
            ),
          ),
          SizedBox(height: 10.h),
          MyTextWidget(
            LocaleKeys.why_we_know_you_label.tr(),
            textAlign: TextAlign.center,
            style: context.textTheme.titleLarge?.lq.copyWith(
              color: const Color(0xffF85555),
              letterSpacing: 0.14,
              height: 1.43,
            ),
          ),
          SizedBox(height: 20.h),
          InkWell(
            key: TestVariables.kTestMode
                ? const Key(WidgetsKeys.haveAccountButtonKey)
                : null,
            highlightColor: Colors.transparent,
            splashColor: Colors.transparent,
            onTap: () async {
              clickButton.value = 0;
              Future.delayed(const Duration(milliseconds: 100), () {
                debugPrint(
                  "/////// user_id : ${prefsRepository.myUserId.toString()} ///////",
                );
                debugPrint(
                  "/////// user_name: ${prefsRepository.userName.toString()} ///////",
                );
                clickButton.value = -1;
                widget.goToScanQrCode.call();
              });
            },
            child: ValueListenableBuilder<int>(
              valueListenable: clickButton,
              builder: (context, index, _) {
                return Padding(
                  padding: const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 0.0),
                  child: DottedBorder(
                    padding: EdgeInsets.zero,
                    strokeCap: StrokeCap.round,
                    strokeWidth: 0.5,
                    borderType: BorderType.RRect,
                    dashPattern: const [3, 3],
                    radius: const Radius.circular(20.0),
                    color: index == 0
                        ? const Color(0xff707070)
                        : const Color(0xfffafafa),
                    child: Container(
                      width: 1.sw,
                      height: 50.h,
                      decoration: BoxDecoration(
                        color: index == 0
                            ? Colors.white
                            : const Color(0xfffafafa),
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      child: Center(
                        child: MyTextWidget(
                          LocaleKeys.methods_login_scan_qr_option.tr(),
                          style: context.textTheme.displayMedium?.rq.copyWith(
                            color: const Color(0xff5D5C5D),
                            letterSpacing: 0.16,
                            height: 1.25,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          SizedBox(height: 10.h),
          InkWell(
            key: TestVariables.kTestMode
                ? const Key(WidgetsKeys.createNewAccountButtonKey)
                : null,
            highlightColor: Colors.transparent,
            splashColor: Colors.transparent,
            onTap: () async {
              clickButton.value = 1;
              Future.delayed(const Duration(milliseconds: 100), () {
                clickButton.value = -1;
                widget.goToAddPhone.call();
              });
            },
            child: ValueListenableBuilder<int>(
              valueListenable: clickButton,
              builder: (context, index, _) {
                return Padding(
                  padding: const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 0.0),
                  child: DottedBorder(
                    padding: EdgeInsets.zero,
                    strokeCap: StrokeCap.round,
                    strokeWidth: 0.5,
                    borderType: BorderType.RRect,
                    dashPattern: const [3, 3],
                    radius: const Radius.circular(20.0),
                    color: index == 1
                        ? const Color(0xff707070)
                        : const Color(0xfffafafa),
                    child: Container(
                      width: 1.sw,
                      height: 50.h,
                      decoration: BoxDecoration(
                        color: index == 1
                            ? Colors.white
                            : const Color(0xfffafafa),
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      child: Center(
                        child: MyTextWidget(
                          LocaleKeys.methods_login_phone_option.tr(),
                          style: context.textTheme.displayMedium?.rq.copyWith(
                            color: const Color(0xff5D5C5D),
                            letterSpacing: 0.16,
                            height: 1.25,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          SizedBox(height: 80.h),
        ],
      ),
    );
  }
}
