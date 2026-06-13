import 'package:dotted_border/dotted_border.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:rdb/common/constant/design/assets_provider.dart';
import 'package:rdb/core/utils/extensions/build_context.dart';
import 'package:rdb/features/app/my_text_widget.dart';
import 'package:rdb/generated/locale_keys.g.dart';
import 'package:rdb/theme/typography.dart';
import 'reset_shimmer.dart';

/// الصفحة الأولى في تدفّق "Forget Passcode": مقدّمة + زرّ بدء إعادة التعيين.
/// نسخة مستقلّة ضمن reset_passcode_widgets (لا تعتمد على widgets تسجيل الدخول).
class ForgetPasscodeIntro extends StatelessWidget {
  const ForgetPasscodeIntro({
    required this.onStart,
    this.isLoading = false,
    super.key,
  });

  final VoidCallback onStart;

  /// أثناء طلب init/questions: الزرّ يصبح shimmer بنفس حجمه.
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Text(
              LocaleKeys.reset_forget_passcode_title.tr(),
              textAlign: TextAlign.start,
              style: context.textTheme.titleMedium?.bq.copyWith(
                color: const Color(0xff1D1D1D),
                height: 1.25,
                fontSize: 30.sp,
              ),
            ),
          ),
          10.verticalSpace,
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Text(
              LocaleKeys.reset_you_can_start.tr(),
              textAlign: TextAlign.start,
              style: context.textTheme.titleMedium?.mq.copyWith(
                color: const Color(0xff1D1D1D),
                height: 1.25,
                fontSize: 16.sp,
              ),
            ),
          ),
          10.verticalSpace,
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Text(
              LocaleKeys.reset_dont_worry_steps.tr(),
              textAlign: TextAlign.start,
              style: context.textTheme.titleMedium?.rq.copyWith(
                color: const Color(0xff1D1D1D),
                height: 1.42,
                fontSize: 12.sp,
              ),
            ),
          ),
          const Spacer(),
          Center(
            child: SvgPicture.asset(
              AppAssets.privacySvg,
              width: 20.w,
              height: 20.h,
              color: Color(0xff388CFF),
            ),
          ),
          8.verticalSpace,
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: _securityNote(
              context,
              LocaleKeys.reset_security_note_1.tr(),
            ),
          ),
          20.verticalSpace,
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: _securityNote(
              context,
              LocaleKeys.reset_security_note_2.tr(),
            ),
          ),
          20.verticalSpace,
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: _securityNote(
              context,
              LocaleKeys.reset_security_note_3.tr(),
            ),
          ),
          10.verticalSpace,

          if (isLoading)
            ResetButtonShimmer(height: 58.h, radius: 20.r)
          else
            InkWell(
            onTap: onStart,
            borderRadius: BorderRadius.circular(20.r),
            child: DottedBorder(
              strokeCap: StrokeCap.round,
              strokeWidth: 0.5,
              borderType: BorderType.RRect,
              dashPattern: const [3, 3],
              padding: EdgeInsets.all(1.h),

              radius: Radius.circular(20.r),
              color: const Color(0xff1D1D1D),
              child: Container(
                width: 1.sw,
                height: 58.h,

                decoration: BoxDecoration(
                  color: const Color(0xffFCFCFC),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Center(
                  child: MyTextWidget(
                    LocaleKeys.reset_start_button.tr(),
                    style: context.textTheme.displayMedium?.mq.copyWith(
                      color: const Color(0xff1D1D1D),
                      letterSpacing: 0.16,
                      height: 1.25,
                      fontSize: 16.sp,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ),
          35.verticalSpace,
        ],
      ),
    );
  }

  Widget _securityNote(BuildContext context, String text) {
    return Text(
      text,
      textAlign: TextAlign.center,
      style: context.textTheme.titleMedium?.rq.copyWith(
        color: const Color(0xff388CFF),
        height: 1.42,
        fontSize: 12.sp,
      ),
    );
  }
}
