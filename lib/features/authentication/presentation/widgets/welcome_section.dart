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
            color: const Color(0xff1D1D1D),
            letterSpacing: 0.14,
            height: 1.3,
            fontSize: 30.sp,
          ),
        ),
        SizedBox(height: 20.h),
        Padding(
          padding: HWEdgeInsets.symmetric(horizontal: 20.w),
          child: MyTextWidget(
            LocaleKeys.welcome_page_description.tr(),
            textAlign: TextAlign.center,
            style: context.textTheme.titleLarge?.rq.copyWith(
              color: const Color(0xff5D5C5D),
              letterSpacing: 0.14,
              height: 1.3,
              fontSize: 13.sp,
            ),
          ),
        ),

        SizedBox(height: 40.h),
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
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: DottedBorder(
                  strokeCap: StrokeCap.round,
                  strokeWidth: 0.5,
                  borderType: BorderType.RRect,
                  dashPattern: const [3, 3],
                  padding: EdgeInsets.all(1.h),

                  radius: Radius.circular(20.r),
                  color: const Color(0xff5D5C5D),
                  child: Container(
                    width: 1.sw,
                    height: 58.h,

                    decoration: BoxDecoration(
                      color: const Color(0xffFCFCFC),
                      borderRadius: BorderRadius.circular(20.r),
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
        SizedBox(height: 8.h),
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
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: DottedBorder(
              strokeCap: StrokeCap.round,
              strokeWidth: 0.5,
              borderType: BorderType.RRect,
              dashPattern: const [3, 3],
              padding: EdgeInsets.all(1.h),

              radius: Radius.circular(20.r),
              color: const Color(0xff5D5C5D),
              child: Container(
                width: 1.sw,
                height: 58.h,
                decoration: BoxDecoration(
                  color: const Color(0xffFCFCFC),
                  borderRadius: BorderRadius.circular(20.r),
                ),

                child: Center(
                  child: ValueListenableBuilder<int>(
                    valueListenable: clickButton,
                    builder: (context, index, _) {
                      return MyTextWidget(
                        LocaleKeys.new_customer.tr(),
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
        SizedBox(height: 30.h),
        MyTextWidget(
          LocaleKeys.later_take_look.tr(),
          textAlign: TextAlign.center,
          style: context.textTheme.titleLarge?.rq.copyWith(
            color: Color(0xff4D84FF),
            letterSpacing: 0.14,
            height: 1.43,
            fontSize: 13.sp,
          ),
        ),
        SizedBox(height: 55.h),
      ],
    );
  }
}
