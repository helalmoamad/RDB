import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
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
      _prefsRepository.setShouldShowPin(false);
      Future.delayed(const Duration(seconds: 3), () {
        if (!mounted) {
          return;
        }

        context.go(GRouter.config.applicationRoutes.kBasePage);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    FlutterError.onError = (FlutterErrorDetails error) {
      LastPagesTracker.sendErrorToBlocAndLog(error);
      FlutterError.dumpErrorToConsole(error);
    };

    final userName = (_prefsRepository.userName ?? '').trim();

    final languageCode = context.locale.languageCode.toLowerCase();
    final isRtlLanguage = languageCode == 'ar' || languageCode == 'ku';
    final textAlign = isRtlLanguage ? TextAlign.right : TextAlign.left;
    final textAlignment = isRtlLanguage
        ? Alignment.centerRight
        : Alignment.centerLeft;

    return Scaffold(
      backgroundColor: const Color(0xffE0FFEE),
      body: PopScope(
        canPop: false,
        child: Padding(
          padding: EdgeInsetsDirectional.only(start: 40.w, end: 40.w),
          child: SizedBox(
            width: double.infinity,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 290.h),
                Align(
                  alignment: textAlignment,
                  child: Text(
                    LocaleKeys.welcome_exclamation.tr(),
                    textAlign: textAlign,
                    style: context.textTheme.titleLarge?.bq.copyWith(
                      color: const Color(0xff1D1D1D),
                      height: 1.25,
                      fontSize: 30.sp,
                    ),
                  ),
                ),
                if (userName.isNotEmpty) ...[
                  10.verticalSpace,
                  Align(
                    alignment: textAlignment,
                    child: Text(
                      userName,
                      textAlign: textAlign,
                      style: context.textTheme.displayMedium?.mq.copyWith(
                        color: const Color(0xff1D1D1D),
                        height: 1.25,
                        fontSize: 14.sp,
                      ),
                    ),
                  ),
                ],
                10.verticalSpace,
                Align(
                  alignment: textAlignment,
                  child: Text(
                    LocaleKeys.enjoy_with_services.tr(),
                    textAlign: textAlign,
                    style: context.textTheme.titleLarge?.mq.copyWith(
                      color: const Color(0xff1D1D1D),
                      height: 1.25,
                      fontSize: 12.sp,
                    ),
                  ),
                ),
                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
