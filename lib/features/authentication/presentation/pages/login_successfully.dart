import 'dart:async';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:rdb/core/domin/repositories/prefs_repository.dart';
import 'package:rdb/core/utils/extensions/build_context.dart';
import 'package:rdb/theme/typography.dart';
import 'package:rdb/generated/locale_keys.g.dart';
import '../../../../core/utils/theme_state.dart';
import '../../../../routes/router.dart';
import 'package:rdb/core/utils/last_pages_tracker.dart';

class LoginSuccessfully extends StatefulWidget {
  const LoginSuccessfully({
    required this.phoneNumber,
    required this.fromLogin,
    super.key,
  });
  final String phoneNumber;
  final bool fromLogin;

  @override
  State<LoginSuccessfully> createState() => _LoginSuccessfullyState();
}

class _LoginSuccessfullyState extends ThemeState<LoginSuccessfully> {
  final PrefsRepository _prefsRepository = GetIt.I<PrefsRepository>();

  // عقدة تركيز غير-نصّية تُمسك التركيز طوال ظهور هذه الصفحة. صفحة النجاح
  // متداخلة فوق RegistrationPage التي تبقى حيّة تحتها (وفيها خانات الـ OTP)،
  // فإمساك التركيز بعقدة غير-نصّية يُغلق اتصال الإدخال ويمنع أي خانة سفلية
  // من إعادة إظهار لوحة المفاتيح.
  final FocusNode _screenFocus = FocusNode(
    debugLabel: 'loginSuccessNoKeyboard',
  );

  void _suppressKeyboard() {
    if (!mounted) return;
    _screenFocus.requestFocus();
    SystemChannels.textInput.invokeMethod('TextInput.hide');
  }

  @override
  void initState() {
    super.initState();

    // هذه الصفحة لا تحتوي أي حقل إدخال. الحماية الأساسية هي Focus(autofocus)
    // الذي يمسك التركيز بعقدة غير-نصّية فور البناء؛ ونكبت اللوحة لحظياً + بعد
    // أول إطار كتأمين إضافي (دون حاجة لحلقة دورية).
    _suppressKeyboard();
    WidgetsBinding.instance.addPostFrameCallback((_) => _suppressKeyboard());

    Future.delayed(const Duration(seconds: 3), () {
      // إزالة التركيز عن أي عنصر قابل للتحرير قبل الانتقال
      FocusManager.instance.primaryFocus?.unfocus();
      final hasStoredName = (_prefsRepository.userName ?? '').trim().isNotEmpty;

      // ignore: use_build_context_synchronously
      context.go(
        widget.fromLogin
            ? GRouter.config.applicationRoutes.kPinCodeVerifyFromLoginPage
            : hasStoredName
            ? GRouter.config.applicationRoutes.kPinCodeSetupPage
            : GRouter.config.applicationRoutes.kEnterNamePage,
      );
    });

    LastPagesTracker.push('LoginSuccessfully');
  }

  @override
  void dispose() {
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
      backgroundColor: const Color(0xffE0FFEE),
      // عقدة تركيز غير-نصّية مربوطة فعلياً بالشجرة وتلتقط التركيز فور البناء
      // (autofocus)، فتسحبه من خانة الـ OTP الحيّة أسفل هذه الصفحة وتُغلق
      // اللوحة فوراً دون ومضة. requestFocus على عقدة غير مربوطة لا يكفي.
      body: Focus(
        focusNode: _screenFocus,
        autofocus: true,
        child:
            // ignore: deprecated_member_use
            WillPopScope(
              onWillPop: () async {
                return false;
              },
              child: SizedBox(
                width: 1.sw,
                height: 1.sh,

                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 40.w),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(height: 300.h),
                      Text(
                        (widget.fromLogin
                                ? LocaleKeys.sign_in_successfully_exclamation
                                : LocaleKeys.sign_up_successfully_exclamation)
                            .tr(),
                        textAlign: TextAlign.start,
                        style: context.textTheme.titleMedium?.mq.copyWith(
                          color: const Color(0xff1D1D1D),
                          height: 1.25,
                          fontSize: 30.sp,
                        ),
                      ),
                      10.verticalSpace,
                      Text(
                        LocaleKeys.enjoy_with_services.tr(),
                        textAlign: TextAlign.start,
                        style: context.textTheme.titleMedium?.mq.copyWith(
                          color: const Color(0xff1D1D1D),
                          height: 1.25,
                          fontSize: 16.sp,
                        ),
                      ),
                      const Spacer(),
                    ],
                  ),
                ),
              ),
            ),
      ),
    );
  }
}
