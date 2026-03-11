import 'package:dotted_border/dotted_border.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:rdb/common/test_utils/test_var.dart';
import 'package:rdb/core/utils/extensions/build_context.dart';
import 'package:rdb/generated/locale_keys.g.dart';
import 'package:rdb/theme/typography.dart';
import '../../../../common/constant/design/assets_provider.dart';
import '../../../../common/test_utils/widgets_keys.dart';

import '../../../app/my_text_widget.dart';
import 'package:rdb/core/utils/last_pages_tracker.dart';

class CreateAccountSection extends StatefulWidget {
  const CreateAccountSection({super.key, required this.moveToNextStep});
  final void Function() moveToNextStep;

  @override
  State<CreateAccountSection> createState() => _CreateAccountSectionState();
}

class _CreateAccountSectionState extends State<CreateAccountSection> {
  final ValueNotifier<int> clickButton = ValueNotifier(-1);

  @override
  Widget build(BuildContext context) {
    FlutterError.onError = (FlutterErrorDetails error) {
      LastPagesTracker.sendErrorToBlocAndLog(error);
      FlutterError.dumpErrorToConsole(error);
    };
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: LocaleKeys.to.tr(),
                style: context.textTheme.titleLarge?.lq.copyWith(
                  color: const Color(0xff5d5c5d),
                  letterSpacing: 0.14,
                  height: 1.43,
                ),
              ),
              TextSpan(
                text: LocaleKeys.create_new_account.tr(),
                style: context.textTheme.titleLarge?.lq.copyWith(
                  color: const Color(0xff5d5c5d),
                  letterSpacing: 0.14,
                  height: 1.43,
                ),
              ),
              TextSpan(
                text:
                    " ${LocaleKeys.tap.tr()} “${LocaleKeys.agree_continue.tr()}” ${LocaleKeys.to_accept_rdb.tr()}",
                style: context.textTheme.titleLarge?.lq.copyWith(
                  color: const Color(0xff5d5c5d),
                  letterSpacing: 0.14,
                  height: 1.43,
                ),
              ),
              TextSpan(
                text: "\n${LocaleKeys.rdb.tr()}",
                style: context.textTheme.titleLarge?.lq.copyWith(
                  color: const Color(0xff5d5c5d),
                  letterSpacing: 0.14,
                  height: 1.2,
                ),
              ),
            ],
          ),
          textHeightBehavior: const TextHeightBehavior(
            applyHeightToFirstAscent: false,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 20.h),
        SvgPicture.asset(AppAssets.termsSvg),
        SizedBox(height: 10.h),
        MyTextWidget(
          LocaleKeys.trems_of_services.tr(),
          style: context.textTheme.titleLarge?.rq.copyWith(
            color: const Color(0xff388CFF),
            height: 1.42,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 60.h),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: InkWell(
            key: TestVariables.kTestMode
                ? const Key(WidgetsKeys.agreeContinueButtonKey)
                : null,
            highlightColor: Colors.transparent,
            splashColor: Colors.transparent,
            onTap: () {
              clickButton.value = 0;
              Future.delayed(const Duration(milliseconds: 100), () {
                clickButton.value = -1;
                widget.moveToNextStep.call();
              });
              /////////////////////////////////////
            },
            child: ValueListenableBuilder<int>(
              valueListenable: clickButton,
              builder: (context, index, _) {
                return DottedBorder(
                  padding: EdgeInsets.zero,
                  borderType: BorderType.RRect,
                  strokeCap: StrokeCap.round,
                  strokeWidth: 0.5,
                  dashPattern: const [3, 3],
                  radius: const Radius.circular(20.0),
                  color: index == 0
                      ? const Color(0xff388cff)
                      : const Color(0xfffafafa),
                  child: Container(
                    width: 1.sw,
                    height: 50.h,
                    decoration: BoxDecoration(
                      color: index == 0
                          ? Colors.white
                          : const Color(0xfffafafa),
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    child: Center(
                      child: MyTextWidget(
                        LocaleKeys.agree_continue.tr(),
                        style: context.textTheme.displayMedium?.rq.copyWith(
                          color: const Color(0xff3c3c3c),
                          letterSpacing: 0.16,
                          height: 1.25,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),

        const SizedBox(height: 80),
      ],
    );
  }
}
