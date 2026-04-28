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

  @override
  void didChangeDependencies() async {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Color(0xffE0FFEE),
        statusBarBrightness: Brightness.light,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) {
        return;
      }

      final hasStoredName = (_prefsRepository.userName ?? '').trim().isNotEmpty;
      context.go(
        hasStoredName
            ? GRouter.config.applicationRoutes.kPinCodePage
            : GRouter.config.applicationRoutes.kEnterNamePage,
      );
    });
    super.didChangeDependencies();
  }

  @override
  void initState() {
    LastPagesTracker.push('LoginSuccessfully');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    FlutterError.onError = (FlutterErrorDetails error) {
      LastPagesTracker.sendErrorToBlocAndLog(error);
      FlutterError.dumpErrorToConsole(error);
    };
    return Scaffold(
      backgroundColor: const Color(0xffE0FFEE),
      body:
          // ignore: deprecated_member_use
          WillPopScope(
            onWillPop: () async {
              return false;
            },
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
    );
  }
}
