import 'package:dotted_border/dotted_border.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart' show ValueListenable;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rdb/core/utils/extensions/build_context.dart';
import 'package:rdb/features/authentication/data/models/reset_passcode_models.dart';
import 'package:rdb/features/authentication/presentation/manager/auth_bloc.dart';
import 'package:rdb/generated/locale_keys.g.dart';
import 'package:rdb/theme/typography.dart';
import 'reset_shimmer.dart';

/// صفحة سؤال أمني واحد ضمن تدفّق إعادة تعيين رمز المرور.
/// عنوان "Reset Passcode!" باهت + النصّ التعريفي، ثم صندوق أزرق بالسؤال،
/// ثم خيارات الإجابة، وأسفلها شريط أزرار:
///  - Previous: يظهر عندما لا نكون على السؤال الأول.
///  - Submit (+ مؤقّت + نص توضيحي فوقه): يظهر عند الإجابة على كل الأسئلة.
class ResetQuestionPage extends StatelessWidget {
  const ResetQuestionPage({
    required this.question,
    required this.selected,
    required this.onAnswer,
    required this.showPrevious,
    required this.onPrevious,
    required this.showSubmit,
    required this.submitCountdown,
    required this.onSubmit,
    super.key,
  });

  final ResetQuestion question;
  final String? selected; // optionId المختار
  final void Function(String optionId) onAnswer;
  final bool showPrevious;
  final VoidCallback onPrevious;
  final bool showSubmit;
  final ValueListenable<int> submitCountdown;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: IntrinsicHeight(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // العنوان الباهت + النصّ التعريفي (موحّد مع بقية الصفحات).
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 40.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          LocaleKeys.reset_passcode_title.tr(),
                          style: context.textTheme.titleMedium?.bq.copyWith(
                            color: const Color(0xffC3C3C3),
                            height: 1.25,
                            fontSize: 30.sp,
                          ),
                        ),
                        10.verticalSpace,
                        Text(
                          LocaleKeys.reset_dont_worry_steps.tr(),
                          style: context.textTheme.titleMedium?.rq.copyWith(
                            color: const Color(0xffC3C3C3),
                            height: 1.42,
                            fontSize: 12.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                  20.verticalSpace,
                  // صندوق السؤال الأزرق.
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: Container(
                      width: 1.sw,
                      height: 105.h,
                      decoration: BoxDecoration(
                        color: const Color(0xff315391),
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      alignment: Alignment.center,
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        child: Text(
                          question.text,
                          textAlign: TextAlign.center,
                          style: context.textTheme.titleMedium?.mq.copyWith(
                            color: const Color(0xffFCFCFC),
                            height: 1.35,
                            fontSize: 14.sp,
                          ),
                        ),
                      ),
                    ),
                  ),
                  7.verticalSpace,
                  // خيارات الإجابة.
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: Column(
                      children: [
                        for (final option in question.options) ...[
                          _OptionButton(
                            label: option.label,
                            isSelected: selected == option.id,
                            onTap: () => onAnswer(option.id),
                          ),
                          5.verticalSpace,
                        ],
                      ],
                    ),
                  ),
                  const Spacer(),
                  // شريط الأزرار السفلي (Previous / Submit).
                  _bottomBar(context),
                  20.verticalSpace,
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _bottomBar(BuildContext context) {
    final previousButton = _PreviousButton(onTap: onPrevious);

    if (showSubmit) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              LocaleKeys.reset_review_answers.tr(),
              textAlign: TextAlign.center,
              style: context.textTheme.titleMedium?.rq.copyWith(
                color: const Color(0xffC3C3C3),
                height: 1.4,
                fontSize: 11.sp,
              ),
            ),
            12.verticalSpace,
            Row(
              children: [
                Expanded(
                  child: BlocBuilder<AuthBloc, AuthState>(
                    buildWhen: (p, c) =>
                        p.resetAnswersStatus != c.resetAnswersStatus,
                    builder: (context, s) =>
                        s.resetAnswersStatus == ResetAnswersStatus.loading
                        ? ResetButtonShimmer(height: 56.h, radius: 20.r)
                        : _SubmitButton(
                            countdown: submitCountdown,
                            onSubmit: onSubmit,
                          ),
                  ),
                ),
                if (showPrevious) ...[12.horizontalSpace, previousButton],
              ],
            ),
          ],
        ),
      );
    }

    if (showPrevious) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: Align(
          alignment: Alignment.centerRight,
          child: previousButton,
        ),
      );
    }

    return const SizedBox.shrink();
  }
}

/// زرّ خيار إجابة بحدود منقّطة (يتلوّن أزرق عند الاختيار).
class _OptionButton extends StatelessWidget {
  const _OptionButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      highlightColor: Colors.transparent,
      splashColor: Colors.transparent,
      borderRadius: BorderRadius.circular(20.r),
      child: DottedBorder(
        padding: const EdgeInsets.all(0.5),
        borderType: BorderType.RRect,
        strokeCap: StrokeCap.round,
        strokeWidth: 0.5,
        dashPattern: const [3, 3],
        radius: Radius.circular(20.r),
        color: isSelected ? const Color(0xffFCFCFC) : const Color(0xff1D1D1D),
        child: Container(
          width: 1.sw,
          height: 56.h,
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xff388CFF)
                : const Color(0xffFCFCFC),
            borderRadius: BorderRadius.circular(20.r),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: context.textTheme.titleMedium?.rq.copyWith(
              color: const Color(0xff1D1D1D),
              height: 1.25,
              fontSize: 16.sp,
            ),
          ),
        ),
      ),
    );
  }
}

/// زرّ الإرسال: معطّل خلال العدّ ويعرض "Submit in Ns"، ويُفعّل عند الصفر.
class _SubmitButton extends StatelessWidget {
  const _SubmitButton({required this.countdown, required this.onSubmit});

  final ValueListenable<int> countdown;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: countdown,
      builder: (context, sec, _) {
        final enabled = sec <= 0;
        return InkWell(
          onTap: enabled ? onSubmit : null,
          borderRadius: BorderRadius.circular(20.r),
          child: Container(
            height: 56.h,
            decoration: BoxDecoration(
              color: enabled
                  ? const Color(0xff2E4C8E)
                  : const Color(0xffEDEDED),
              borderRadius: BorderRadius.circular(20.r),
            ),
            alignment: Alignment.center,
            child: Text(
              enabled
                  ? LocaleKeys.reset_submit.tr()
                  : LocaleKeys.reset_submit_in.tr(args: ['$sec']),
              style: context.textTheme.titleMedium?.rq.copyWith(
                color: enabled ? Colors.white : const Color(0xff9E9E9E),
                height: 1.25,
                fontSize: 16.sp,
              ),
            ),
          ),
        );
      },
    );
  }
}

/// زرّ الرجوع للسؤال السابق "Previous ‹".
class _PreviousButton extends StatelessWidget {
  const _PreviousButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20.r),
      child: Container(
        height: 56.h,
        padding: EdgeInsets.symmetric(horizontal: 22.w),
        decoration: BoxDecoration(
          color: const Color(0xffFCFCFC),
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: const Color(0xffC3C3C3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              LocaleKeys.reset_previous.tr(),
              style: context.textTheme.titleMedium?.rq.copyWith(
                color: const Color(0xff1D1D1D),
                height: 1.25,
                fontSize: 15.sp,
              ),
            ),
            4.horizontalSpace,
            Icon(
              Icons.chevron_left,
              size: 18.sp,
              color: const Color(0xff1D1D1D),
            ),
          ],
        ),
      ),
    );
  }
}
