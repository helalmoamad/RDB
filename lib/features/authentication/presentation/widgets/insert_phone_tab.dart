import 'package:country_flags/country_flags.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:rdb/common/test_utils/test_var.dart';
import 'package:rdb/core/utils/extensions/build_context.dart';
import 'package:rdb/core/utils/form_utils.dart';
import 'package:rdb/features/app/rdb_loading.dart';
import 'package:rdb/features/authentication/presentation/widgets/phone_form_fields.dart';
import 'package:rdb/generated/locale_keys.g.dart';
import 'package:rdb/core/utils/last_pages_tracker.dart';
import 'package:rdb/service/language_service.dart';
import 'package:rdb/theme/typography.dart';
import '../../../../common/constant/countries.dart';
import '../../../../common/constant/design/assets_provider.dart';
import '../../../../common/test_utils/widgets_keys.dart';
import '../../../../core/utils/form_state_mixin.dart';
import '../../../../core/utils/responsive_padding.dart';
import '../../../app/my_text_widget.dart';

class InsertPhoneTab extends StatefulWidget {
  const InsertPhoneTab({
    this.fromLogin = false,
    required this.moveToNextStep,
    required this.focusNode,
    super.key,
  });
  final bool fromLogin;
  final void Function(String phoneNumber) moveToNextStep;
  final FocusNode focusNode;

  @override
  State<InsertPhoneTab> createState() => _InsertPhoneTabState();
}

class _InsertPhoneTabState extends State<InsertPhoneTab> with FormStateMinxin {
  final ValueNotifier<Country> countryChanged = ValueNotifier(
    const Country(
      name: '',
      flag: '',
      code: '',
      dialCode: '',
      minLength: 0,
      maxLength: 0,
    ),
  );
  final ValueNotifier<bool> displaySubmit = ValueNotifier(false);
  final ValueNotifier<bool> showLoadingSubmit = ValueNotifier(false);
  final ValueNotifier<bool> changeTextInputFieldContent = ValueNotifier(false);
  int maxLength = 25;

  @override
  void didChangeDependencies() {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Color(0xffFFFFFF),
        statusBarBrightness: Brightness.light,
        statusBarIconBrightness: Brightness.dark,
      ),
    );
    ///////////////////

    ///////////////////
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('yes rebuilt');
    FlutterError.onError = (FlutterErrorDetails error) {
      LastPagesTracker.sendErrorToBlocAndLog(error);
      FlutterError.dumpErrorToConsole(error);
    };
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: HWEdgeInsets.symmetric(horizontal: 10.0.h),
          child: Column(
            children: [
              MyTextWidget(
                widget.fromLogin
                    ? LocaleKeys.sign_in_exclamation.tr()
                    : LocaleKeys.sign_up_exclamation.tr(),
                textAlign: TextAlign.center,
                style: context.textTheme.titleMedium?.bq.copyWith(
                  color: const Color(0xff1D1D1D),
                  height: 1.25,
                  fontSize: 24.sp,
                ),
              ),
              30.verticalSpace,
              SvgPicture.asset(
                AppAssets.phoneCallOutlinedSvg,
                width: 50.w,
                colorFilter: ColorFilter.mode(Colors.grey, BlendMode.srcIn),
              ),
              30.verticalSpace,

              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  MyTextWidget(
                    "${LocaleKeys.enter_your_number.tr()} ${widget.fromLogin ? LocaleKeys.to_login.tr() : LocaleKeys.registered_with_us.tr()}",
                    style: context.textTheme.titleMedium?.rq.copyWith(
                      color: const Color(0xff5D5C5D),
                      height: 1.42,
                      fontSize: 13.sp,
                    ),
                  ),
                  10.verticalSpace,

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset(
                        AppAssets.phoneOtpSvg,
                        width: 10,
                        height: 10,
                      ),
                      10.horizontalSpace,
                      SizedBox(
                        child: MyTextWidget(
                          LocaleKeys.we_will_send_code.tr(),
                          style: context.textTheme.titleMedium?.rq.copyWith(
                            color: const Color(0xff5D5C5D),
                            height: 1.42,
                            fontSize: 13.sp,
                          ),
                        ),
                      ),
                    ],
                  ),
                  10.verticalSpace,
                  LanguageService.rtl
                      ? SizedBox(
                          width: 1.sw - 20,
                          height: 20.h,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Padding(
                                padding: HWEdgeInsets.only(top: 3.0),
                                child: SvgPicture.asset(
                                  AppAssets.privacySvg,
                                  width: 10,
                                  height: 10,
                                ),
                              ),
                              5.horizontalSpace,
                              MyTextWidget(
                                LocaleKeys.your_Privacy.tr(),
                                textAlign: TextAlign.start,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                                style: context.textTheme.titleMedium?.rq
                                    .copyWith(
                                      color: const Color(0xff5D5C5D),
                                      height: 1.42,
                                      fontSize: 13.sp,
                                    ),
                              ),
                            ],
                          ),
                        )
                      : SizedBox(
                          width: 1.sw - 20,
                          height: 20.h,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Padding(
                                  padding: HWEdgeInsets.only(top: 3.0),
                                  child: SvgPicture.asset(
                                    AppAssets.privacySvg,
                                    width: 10,
                                    height: 10,
                                  ),
                                ),
                                5.horizontalSpace,
                                MyTextWidget(
                                  LocaleKeys.your_Privacy.tr(),
                                  textAlign: TextAlign.start,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                  style: context.textTheme.titleMedium?.rq
                                      .copyWith(
                                        color: const Color(0xff5D5C5D),
                                        height: 1.42,
                                        fontSize: 13.sp,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ),
                  SizedBox(height: 3.h),
                ],
              ),
            ],
          ),
        ),
        SizedBox(height: 75.h),
        Padding(
          padding: HWEdgeInsets.symmetric(horizontal: 40.w),
          child: ValueListenableBuilder<bool>(
            valueListenable: displaySubmit,
            builder: (context, display, _) {
              return PhoneFormField(
                onFieldSubmitted: (val) {
                  if (display) {
                    Future.delayed(const Duration(milliseconds: 300), () {
                      if (mounted) {
                        // ignore: use_build_context_synchronously
                        FocusScope.of(context).unfocus();
                      }
                    });
                    showLoadingSubmit.value = true;
                    //////////////////////////
                  }
                },
                key: TestVariables.kTestMode
                    ? const Key(WidgetsKeys.loginPhoneFormFieldKey)
                    : null,
                autoFocus: true,
                onChange: (String? text) {
                  if ((text?.length ?? 0) > 3 &&
                      countryChanged.value.code == "") {
                    if (text!.startsWith("00")) {
                      form.controllers[0].text = text.replaceAll("00", '');
                    } else {
                      form.controllers[0].text = text.replaceFirst(
                        RegExp(r'0'),
                        '',
                      );
                    }
                  }
                  Country newCountry = countries.firstWhere(
                    (element) => '+${form.controllers[0].text.toLowerCase()}'
                        .startsWith(element.dialCode.toLowerCase()),
                    orElse: () => const Country(
                      name: '',
                      flag: '',
                      code: '',
                      dialCode: '',
                      minLength: 0,
                      maxLength: 0,
                    ),
                  );
                  if ((form.controllers[0].text.isNotEmpty) &&
                      newCountry.code != "") {
                    displaySubmit.value =
                        (form.controllers[0].text.replaceAll(' ', '').length) >=
                            (newCountry.minLength +
                                newCountry.dialCode.length -
                                3) &&
                        (form.controllers[0].text.replaceAll(' ', '').length) <=
                            (newCountry.maxLength +
                                newCountry.dialCode.length +
                                3);
                  } else {
                    displaySubmit.value = false;
                  }
                  countryChanged.value = newCountry;
                  debugPrint(
                    'form.controllers[0].text${form.controllers[0].text}',
                  );
                  return form.controllers[0].text.isNotEmpty
                      ? form
                                .controllers[0]
                                .text[form.controllers[0].text.length - 1] ==
                            ' '
                      : false;
                },
                maxLength: maxLength - 1,
                prefixIcon: Padding(
                  padding: HWEdgeInsets.only(left: 20.0.w, top: 0.h),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SvgPicture.asset(AppAssets.phoneCallSvg),
                      10.horizontalSpace,
                      ValueListenableBuilder<Country>(
                        valueListenable: countryChanged,
                        builder: (context, country, _) {
                          if (country.code == '') {
                            return SizedBox(width: 22.w, height: 15.h);
                          } else {
                            return country.code.toUpperCase() == "SY"
                                ? SvgPicture.asset(
                                    AppAssets.syriaFlagSvg,
                                    width: 22.w,
                                  )
                                : CountryFlag.fromCountryCode(
                                    country.code,
                                    height: 15.h,
                                    width: 22.w,
                                    borderRadius: 4.r,
                                  );
                          }
                        },
                      ),
                      10.horizontalSpace,
                      SizedBox(
                        height: 15.h,
                        child: MyTextWidget(
                          '+',
                          style: context.textTheme.bodyMedium?.rq.copyWith(
                            height: 0.9,
                            color: const Color(0xff8E8E8E),
                          ),
                        ),
                      ),

                      2.horizontalSpace,
                    ],
                  ),
                ),
                ready: display,
                suffixIcon: Padding(
                  padding: HWEdgeInsets.only(right: 20.0.w, top: 0.h),
                  child: !display
                      ? SizedBox(width: 22.w, height: 15.h)
                      : InkWell(
                          key: TestVariables.kTestMode
                              ? const Key(
                                  WidgetsKeys.loginConfirmPhoneButtonKey,
                                )
                              : null,
                          onTap: () {
                            Future.delayed(const Duration(seconds: 1), () {
                              if (mounted) {
                                // ignore: use_build_context_synchronously
                                FocusScope.of(context).unfocus();
                              }
                            });
                            showLoadingSubmit.value = true;
                            //////////////////////////
                          },
                          child: ValueListenableBuilder<bool>(
                            valueListenable: showLoadingSubmit,
                            builder: (context, showLoading, _) {
                              if (showLoading) {
                                Future.delayed(Duration(seconds: 2), () {
                                  showLoadingSubmit.value = false;
                                  widget.moveToNextStep.call(
                                    form.controllers[0].text,
                                  );
                                });
                              }
                              return Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  showLoading
                                      ? SizedBox(
                                          width: 30.w,
                                          height: 30.h,
                                          child: RDBLoader(
                                            size: 24.h,
                                            color: Color(0xff1D1D1D),
                                          ),
                                        )
                                      : SvgPicture.asset(
                                          AppAssets.submitArrowSvg,
                                          width: 10.w,
                                          height: 20.h,
                                        ),
                                ],
                              );
                            },
                          ),
                        ),
                ),
                hintText: LocaleKeys.phone_number.tr(),
                controller: form.controllers[0],
              );
            },
          ),
        ),
        SizedBox(height: 150.h),
      ],
    );
  }

  @override
  int get numberOfFields => 1;
}
