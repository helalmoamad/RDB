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
import '../../../../common/test_utils/widgets_keys.dart';
import '../../../../core/domin/repositories/prefs_repository.dart';
import '../../../../core/utils/responsive_padding.dart';
import '../../../app/my_text_widget.dart';

class WelcomeSection extends StatefulWidget {
  const WelcomeSection({
    required this.goToCreateAccount,
    required this.goToLoginSection,
    super.key,
  });
  final void Function() goToCreateAccount;
  final void Function() goToLoginSection;

  @override
  State<WelcomeSection> createState() => _WelcomeSectionState();
}

class _WelcomeSectionState extends State<WelcomeSection> {
  bool _eventLogged = false;
  @override
  void didChangeDependencies() async {
    if (!_eventLogged) {
      _eventLogged = true;
    }

    super.didChangeDependencies();
  }

  final ValueNotifier<int> clickButton = ValueNotifier(-1);

  final PrefsRepository prefsRepository = GetIt.I<PrefsRepository>();

  @override
  Widget build(BuildContext context) {
    FlutterError.onError = (FlutterErrorDetails error) {
      LastPagesTracker.sendErrorToBlocAndLog(error);
      FlutterError.dumpErrorToConsole(error);
    };
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        MyTextWidget(
          LocaleKeys.get_started.tr(),
          textAlign: TextAlign.center,
          style: context.textTheme.titleLarge?.bq.copyWith(
            color: const Color(0xff5D5C5D),
            letterSpacing: 0.14,
            height: 1.3,
            fontSize: 24.sp,
          ),
        ),
        SizedBox(height: 20.h),
        Padding(
          padding: HWEdgeInsets.symmetric(horizontal: 75.w),
          child: MyTextWidget(
            LocaleKeys.welcome_page_description.tr(),
            textAlign: TextAlign.center,
            style: context.textTheme.titleLarge?.lq.copyWith(
              color: const Color(0xff5D5C5D),
              letterSpacing: 0.14,
              height: 1.3,
              fontSize: 13.sp,
            ),
          ),
        ),

        Spacer(),
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
              widget.goToLoginSection.call();
            });
          },
          child: ValueListenableBuilder<int>(
            valueListenable: clickButton,
            builder: (context, index, _) {
              return Padding(
                padding: const EdgeInsets.fromLTRB(50.0, 0.0, 50.0, 0.0),
                child: DottedBorder(
                  padding: EdgeInsets.zero,
                  strokeCap: StrokeCap.round,
                  strokeWidth: 0.5,
                  borderType: BorderType.RRect,
                  dashPattern: const [3, 3],
                  radius: const Radius.circular(20.0),
                  color: const Color(0xfffafafa),
                  child: Container(
                    width: 1.sw,
                    height: 50.h,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: const Color.fromARGB(255, 180, 178, 178),
                      ),
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(15.r),
                    ),
                    child: Center(
                      child: MyTextWidget(
                        LocaleKeys.i_have_account.tr(),
                        style: context.textTheme.displayMedium?.rq.copyWith(
                          color: const Color(0xff5D5C5D),
                          letterSpacing: 0.16,
                          height: 1.25,
                          fontSize: 16.sp,
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

          onTap: () async {
            clickButton.value = 1;
            Future.delayed(const Duration(milliseconds: 100), () {
              clickButton.value = -1;
              widget.goToCreateAccount.call();
            });
          },
          child: Padding(
            padding: const EdgeInsets.fromLTRB(50.0, 0.0, 50.0, 0.0),
            child: DottedBorder(
              padding: EdgeInsets.zero,
              strokeCap: StrokeCap.round,
              strokeWidth: 0.5,
              borderType: BorderType.RRect,
              dashPattern: const [3, 3],
              radius: const Radius.circular(20.0),
              color: const Color(0xfffafafa),
              child: Container(
                width: 1.sw,
                height: 50.h,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: const Color.fromARGB(255, 180, 178, 178),
                  ),
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(15.r),
                ),
                child: Center(
                  child: ValueListenableBuilder<int>(
                    valueListenable: clickButton,
                    builder: (context, index, _) {
                      return MyTextWidget(
                        LocaleKeys.create_new_account.tr(),
                        style: context.textTheme.displayMedium?.rq.copyWith(
                          color: const Color(0xff5D5C5D),
                          letterSpacing: 0.16,
                          fontSize: 16.sp,
                          height: 1.25,
                        ),
                        textAlign: TextAlign.center,
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: 10.h),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          child: MyTextWidget(
            LocaleKeys.later_take_look.tr(),
            textAlign: TextAlign.center,
            style: context.textTheme.titleLarge?.rq.copyWith(
              color: Colors.grey,
              decoration: TextDecoration.underline,
              decorationColor: Colors.grey,
              letterSpacing: 0.14,
              height: 1.43,
              fontSize: 16.sp,
            ),
          ),
        ),
        SizedBox(height: 30.h),
      ],
    );
  }
}
