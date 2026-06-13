import 'package:dotted_border/dotted_border.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rdb/core/utils/extensions/build_context.dart';
import 'package:rdb/generated/locale_keys.g.dart';
import 'package:rdb/theme/typography.dart';

/// صفحة الفشل (محاولة واحدة متبقّية): إجابات غير صحيحة، مع زرّ "أعد المحاولة"
/// الذي يعيد المستخدم لأول سؤال.
class ResetTryAgainPage extends StatelessWidget {
  const ResetTryAgainPage({
    required this.onTryAgain,
    this.attemptsRemaining,
    super.key,
  });

  final VoidCallback onTryAgain;

  /// عدد المحاولات المتبقّية من الباك (يُعرض إن توفّر).
  final int? attemptsRemaining;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 40.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            LocaleKeys.reset_passcode_title.tr(),
            style: context.textTheme.titleMedium?.bq.copyWith(
              color: const Color(0xff1D1D1D),
              height: 1.25,
              fontSize: 30.sp,
            ),
          ),
          10.verticalSpace,
          Text(
            LocaleKeys.reset_failure_message.tr(),
            style: context.textTheme.titleMedium?.rq.copyWith(
              color: const Color(0xffFF5F61),
              height: 1.5,
              fontSize: 12.sp,
            ),
          ),
          if (attemptsRemaining != null) ...[
            8.verticalSpace,
            Text(
              LocaleKeys.reset_attempts_remaining.tr(
                args: ['$attemptsRemaining'],
              ),
              style: context.textTheme.titleMedium?.mq.copyWith(
                color: const Color(0xff5D5C5D),
                height: 1.5,
                fontSize: 13.sp,
              ),
            ),
          ],
          const Spacer(),
          InkWell(
            onTap: onTryAgain,
            borderRadius: BorderRadius.circular(20.r),
            child: DottedBorder(
              padding: const EdgeInsets.all(0.5),
              borderType: BorderType.RRect,
              strokeCap: StrokeCap.round,
              strokeWidth: 0.5,
              dashPattern: const [3, 3],
              radius: Radius.circular(20.r),
              color: const Color(0xff1D1D1D),
              child: Container(
                width: 1.sw,
                height: 60.h,
                decoration: BoxDecoration(
                  color: const Color(0xffFCFCFC),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                alignment: Alignment.center,
                child: Text(
                  LocaleKeys.reset_try_again.tr(),
                  style: context.textTheme.titleMedium?.mq.copyWith(
                    color: const Color(0xff1D1D1D),
                    height: 1.25,
                    fontSize: 16.sp,
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
}

/// صفحة القفل (محاولات متعدّدة فاشلة): لا يمكن المحاولة قبل مدّة، مع شريط سفلي
/// يعرض الوقت المتبقّي. الخروج (X/الرجوع) يغادر تدفّق reset كاملاً.
class ResetLockedPage extends StatelessWidget {
  const ResetLockedPage({this.retryAfter = "04:49", super.key});

  /// الوقت المتبقّي قبل إتاحة المحاولة (يأتي من الباك لاحقاً).
  final String retryAfter;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 40.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                LocaleKeys.reset_passcode_title.tr(),
                style: context.textTheme.titleMedium?.bq.copyWith(
                  color: const Color(0xff1D1D1D),
                  height: 1.25,
                  fontSize: 30.sp,
                ),
              ),
              10.verticalSpace,
              Text(
                LocaleKeys.reset_locked_message.tr(),
                style: context.textTheme.titleMedium?.rq.copyWith(
                  color: const Color(0xffFF5F61),
                  height: 1.5,
                  fontSize: 12.sp,
                ),
              ),
              20.verticalSpace,
              Text.rich(
                TextSpan(
                  text: LocaleKeys.reset_locked_visit_prefix.tr(),
                  style: context.textTheme.titleMedium?.rq.copyWith(
                    color: const Color(0xff1D1D1D),
                    height: 1.5,
                    fontSize: 12.sp,
                  ),
                  children: [
                    TextSpan(
                      text: LocaleKeys.reset_our_centers.tr(),
                      style: context.textTheme.titleMedium?.rq.copyWith(
                        color: const Color(0xff388CFF),
                        height: 1.5,
                        fontSize: 12.sp,
                      ),
                    ),
                    TextSpan(text: LocaleKeys.reset_locked_visit_suffix.tr()),
                  ],
                ),
              ),
            ],
          ),
        ),
        const Spacer(),
        // شريط سفلي: الوقت المتبقّي قبل إتاحة المحاولة.
        Container(
          width: 1.sw,
          margin: EdgeInsets.symmetric(horizontal: 20.w),
          height: 60.h,
          decoration: BoxDecoration(
            color: const Color(0xffFCFCFC),
            borderRadius: BorderRadius.circular(16.r),
          ),
          alignment: Alignment.center,
          child: Text(
            LocaleKeys.reset_try_again_after.tr(args: [retryAfter]),
            style: context.textTheme.titleMedium?.rq.copyWith(
              color: const Color(0xffFF5F61),
              height: 1.25,
              fontSize: 16.sp,
            ),
          ),
        ),
        35.verticalSpace,
      ],
    );
  }
}
