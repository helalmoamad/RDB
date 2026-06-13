import 'dart:async';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:rdb/theme/typography.dart';
import 'package:rdb/common/test_utils/test_var.dart';
import 'package:rdb/core/utils/extensions/build_context.dart';
import 'package:rdb/generated/locale_keys.g.dart';
import 'package:rdb/core/utils/last_pages_tracker.dart';
import '../../../../common/constant/design/assets_provider.dart';
import '../../../../common/test_utils/widgets_keys.dart';
import '../../../../core/domin/repositories/prefs_repository.dart';
import '../../../../core/utils/responsive_padding.dart';
import '../../../../core/utils/theme_state.dart';
import '../../../../routes/router.dart';
import '../../../app/my_text_widget.dart';

class AlreadyExistAccount extends StatefulWidget {
  const AlreadyExistAccount({required this.phoneNumber, super.key});
  final String phoneNumber;
  @override
  State<AlreadyExistAccount> createState() => _AlreadyExistAccountState();
}

class _AlreadyExistAccountState extends ThemeState<AlreadyExistAccount> {
  PrefsRepository prefsRepository = GetIt.I<PrefsRepository>();
  Timer? _keyboardGuardTimer;

  // عقدة تركيز غير-نصّية تُمسك التركيز طوال ظهور هذه الصفحة. هذه الصفحة
  // متداخلة فوق صفحة تبقى حيّة تحتها (وفيها خانات الـ OTP)، فإمساك التركيز
  // بعقدة غير-نصّية يُغلق اتصال الإدخال ويمنع أي خانة سفلية من إعادة إظهار
  // لوحة المفاتيح.
  final FocusNode _screenFocus = FocusNode(
    debugLabel: 'alreadyExistAccountNoKeyboard',
  );

  void _suppressKeyboard() {
    if (!mounted) return;
    _screenFocus.requestFocus();
    SystemChannels.textInput.invokeMethod('TextInput.hide');
  }

  @override
  void initState() {
    LastPagesTracker.push('AlreadyExistAccount');
    super.initState();

    // هذه الصفحة لا تحتوي أي حقل إدخال، فأي لوحة تظهر عليها هي تسريب من
    // خانة الـ OTP في الصفحة الحيّة تحتها. نُبقي حارساً يعيد إمساك التركيز
    // ويُغلق اللوحة طوال مدة ظهور الصفحة (يُلغى عند الانتقال).
    _suppressKeyboard();
    WidgetsBinding.instance.addPostFrameCallback((_) => _suppressKeyboard());
    int ticks = 0;
    _keyboardGuardTimer = Timer.periodic(const Duration(milliseconds: 50), (
      timer,
    ) {
      _suppressKeyboard();
      // حدّ أمان (~4s) في حال لم يُستدعَ dispose لأي سبب.
      if (!mounted || ++ticks >= 80) {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _keyboardGuardTimer?.cancel();
    _screenFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    FlutterError.onError = (FlutterErrorDetails error) {
      LastPagesTracker.sendErrorToBlocAndLog(error);
      FlutterError.dumpErrorToConsole(error);
    };

    return Scaffold(
      // الصفحة بلا حقول إدخال: نمنع أي إعادة تخطيط بسبب اللوحة (دفاع إضافي).
      resizeToAvoidBottomInset: false,
      backgroundColor: const Color(0xffF4F8FF),
      // عقدة تركيز غير-نصّية مربوطة فعلياً بالشجرة وتلتقط التركيز فور البناء
      // (autofocus)، فتسحبه من خانة الـ OTP الحيّة أسفل هذه الصفحة وتُغلق اللوحة.
      body: Focus(
        focusNode: _screenFocus,
        autofocus: true,
        child:
            // ignore: deprecated_member_use
            WillPopScope(
            onWillPop: () async {
              /*  if (pageController.page == 1) {
                    prefsRepository.setUserName("");
                    context.go(
                      '${GRouter.config.applicationRoutes.kRegistrationCompletedPage}?userName=',
                    );
                    return false;
                  }*/
              return false;
            },
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 288.h),
                    Padding(
                      padding: HWEdgeInsets.symmetric(horizontal: 40.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          MyTextWidget(
                            LocaleKeys.already_registered_exclamation.tr(),
                            style: context.textTheme.titleLarge?.bq.copyWith(
                              color: const Color(0xff1D1D1D),
                              height: 1.42,
                              fontSize: 30.sp,
                            ),
                          ),
                          10.verticalSpace,
                          MyTextWidget(
                            LocaleKeys.number_already_registered.tr(),
                            style: context.textTheme.titleLarge?.mq.copyWith(
                              color: const Color(0xff1D1D1D),
                              height: 1.42,
                              fontSize: 16.sp,
                            ),
                          ),
                          10.verticalSpace,
                          Row(
                            children: [
                              MyTextWidget(
                                "+ ${widget.phoneNumber}",
                                textAlign: TextAlign.start,
                                style: context.textTheme.titleMedium?.rq
                                    .copyWith(
                                      color: const Color(0xff1D1D1D),
                                      height: 1.25,
                                      fontSize: 12.sp,
                                    ),
                              ),
                              10.horizontalSpace,
                              SvgPicture.asset(
                                AppAssets.blueQuestion,
                                width: 15.w,
                                height: 15.h,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    InkWell(
                      key: TestVariables.kTestMode
                          ? const Key(WidgetsKeys.createNewAccountContinueKey)
                          : null,
                      onTap: () {
                        FocusManager.instance.primaryFocus?.unfocus();
                        context.go(
                          '${GRouter.config.applicationRoutes.kLoginSuccessfullyPagePath}?phoneNumber=${Uri.encodeQueryComponent(widget.phoneNumber)}&fromLogin=true',
                        );
                      },
                      child: Container(
                        width: 1.sw,
                        height: 60.h,
                        margin: HWEdgeInsets.symmetric(horizontal: 20.w),
                        decoration: BoxDecoration(
                          color: const Color(0xffFAFAFA),
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            MyTextWidget(
                              LocaleKeys.login_continue.tr(),
                              style: textTheme.displayMedium?.rq.copyWith(
                                color: const Color(0xff5D5C5D),
                                letterSpacing: 0.16,
                                height: 1.25,
                                fontSize: 16.sp,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    30.verticalSpace,
                    Center(
                      child: MyTextWidget(
                        LocaleKeys.cancel_take_look.tr(),
                        style: textTheme.displayMedium?.rq.copyWith(
                          color: const Color(0xff4D84FF),
                          letterSpacing: 0.16,
                          height: 1.25,
                          fontSize: 14.sp,
                        ),
                      ),
                    ),
                    SizedBox(height: 54.h),
                  ],
                ),
              ],
            ),
          ),
      ),
    );
  }
}
