import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:rdb/core/domin/repositories/prefs_repository.dart';
import 'package:rdb/core/utils/extensions/build_context.dart';
import 'package:rdb/core/utils/last_pages_tracker.dart';
import 'package:rdb/generated/locale_keys.g.dart';
import 'package:rdb/routes/router.dart';
import 'package:rdb/theme/typography.dart';

class PasscodeWelcomePage extends StatefulWidget {
  const PasscodeWelcomePage({super.key});

  @override
  State<PasscodeWelcomePage> createState() => _PasscodeWelcomePageState();
}

class _PasscodeWelcomePageState extends State<PasscodeWelcomePage> {
  final PrefsRepository _prefsRepository = GetIt.I<PrefsRepository>();

  @override
  void initState() {
    super.initState();
    LastPagesTracker.push('PasscodeWelcomePage');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(seconds: 3), () {
        if (!mounted) {
          return;
        }

        _prefsRepository.setShouldShowPin(false);
        context.go(GRouter.config.applicationRoutes.kBasePage);
      });
    });
  }

  @override
  void didChangeDependencies() {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Color(0xffE0FFEE),
        statusBarBrightness: Brightness.light,
        statusBarIconBrightness: Brightness.light,
      ),
    );
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    FlutterError.onError = (FlutterErrorDetails error) {
      LastPagesTracker.sendErrorToBlocAndLog(error);
      FlutterError.dumpErrorToConsole(error);
    };

    final userName = (_prefsRepository.userName ?? '').trim();

    return Scaffold(
      backgroundColor: const Color(0xffE0FFEE),
      body: PopScope(
        canPop: false,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 40.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 288.h),
              Text(
                LocaleKeys.welcome_exclamation.tr(),
                textAlign: TextAlign.start,
                style: context.textTheme.titleLarge?.bq.copyWith(
                  color: const Color(0xff1D1D1D),
                  height: 1.25,
                  fontSize: 30.sp,
                ),
              ),
              if (userName.isNotEmpty) ...[
                10.verticalSpace,
                Text(
                  userName,
                  textAlign: TextAlign.start,
                  style: context.textTheme.displayMedium?.mq.copyWith(
                    color: const Color(0xff1D1D1D),
                    height: 1.25,
                    fontSize: 14.sp,
                  ),
                ),
              ],
              10.verticalSpace,
              Text(
                LocaleKeys.enjoy_with_services.tr(),
                textAlign: TextAlign.start,
                style: context.textTheme.titleLarge?.mq.copyWith(
                  color: const Color(0xff1D1D1D),
                  height: 1.25,
                  fontSize: 12.sp,
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
