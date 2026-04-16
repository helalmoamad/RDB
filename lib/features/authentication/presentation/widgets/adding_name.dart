/*import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:rdb/common/helper/show_message.dart';
import 'package:rdb/common/test_utils/test_var.dart';
import 'package:rdb/core/utils/extensions/build_context.dart';
import 'package:rdb/core/utils/form_utils.dart';
import 'package:rdb/features/authentication/presentation/widgets/name_from_field.dart';
import 'package:rdb/generated/locale_keys.g.dart';
import 'package:rdb/theme/typography.dart';
import '../../../../common/constant/design/assets_provider.dart';
import '../../../../common/test_utils/widgets_keys.dart';
import '../../../../core/domin/repositories/prefs_repository.dart';
import '../../../../core/utils/form_state_mixin.dart';
import '../../../../core/utils/responsive_padding.dart';
import '../../../../routes/router.dart';
import '../../../app/my_text_widget.dart';
import '../manager/auth_bloc.dart';
import 'package:rdb/core/utils/last_pages_tracker.dart';

class AddingName extends StatefulWidget {
  const AddingName({required this.fromLogin, super.key});
  final bool fromLogin;

  @override
  State<AddingName> createState() => _AddingNameState();
}

class _AddingNameState extends State<AddingName> with FormStateMinxin {
  final ValueNotifier<bool> displaySubmit = ValueNotifier(false);
  PrefsRepository prefsRepository = GetIt.I<PrefsRepository>();

  @override
  void didChangeDependencies() {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Color(0xffF4FFF4),
        statusBarBrightness: Brightness.light,
        statusBarIconBrightness: Brightness.dark,
      ),
    );

    super.didChangeDependencies();
  }

  @override
  void initState() {
    context.go(GRouter.config.applicationRoutes.kBasePage);
    super.initState();
  }

  final GlobalKey<FormState> _formkey = GlobalKey();
  @override
  Widget build(BuildContext context) {
    FlutterError.onError = (FlutterErrorDetails error) {
      LastPagesTracker.sendErrorToBlocAndLog(error);
      FlutterError.dumpErrorToConsole(error);
    };
    bool updateNameLoading = false;
    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (p, c) => p.verifyOtpSignUpStatus != c.verifyOtpSignUpStatus,
      listener: (context, state) {
        if (state.verifyOtpSignUpStatus == VerifyOtpSignUpStatus.failure) {
          showWarningMessage(
            context,
            state.signUpErrorMessage ?? LocaleKeys.no_error_message.tr(),
          );
          return;
        }
        if (state.verifyOtpSignUpStatus == VerifyOtpSignUpStatus.loading) {
          updateNameLoading = true;
        }
        if (state.verifyOtpSignUpStatus == VerifyOtpSignUpStatus.success) {
          context.go(
            '${GRouter.config.applicationRoutes.kRegistrationCompletedPage}?userName=${form.controllers[0].text}',
          );
        }
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Padding(
            padding: HWEdgeInsets.symmetric(horizontal: 40.0),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SvgPicture.asset(
                      AppAssets.verifiedNumberSvg,
                      width: 15,
                      height: 15,
                    ),
                    10.horizontalSpace,
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        MyTextWidget(
                          LocaleKeys.the_number_verifieds_successfully.tr(),
                          style: context.textTheme.titleMedium?.rq.copyWith(
                            color: const Color(0xff5D5C5D),
                            height: 1.42,
                          ),
                        ),
                        Row(
                          children: [
                            Padding(
                              padding: HWEdgeInsets.only(top: 3.0),
                              child: SvgPicture.asset(
                                AppAssets.registerInfoSvg,
                                width: 10,
                                height: 10,
                              ),
                            ),
                            5.horizontalSpace,
                            MyTextWidget(
                              LocaleKeys.last_step.tr(),
                              textAlign: TextAlign.start,
                              style: context.textTheme.titleMedium?.rq.copyWith(
                                color: const Color(0xffC4C2C2),
                                height: 1.25,
                              ),
                            ),
                          ],
                        ),
                        5.verticalSpace,
                        Row(
                          children: [
                            SvgPicture.asset(
                              AppAssets.privacySvg,
                              width: 10,
                              height: 10,
                            ),
                            5.horizontalSpace,
                            MyTextWidget(
                              LocaleKeys.your_Privacy.tr(),
                              style: context.textTheme.titleMedium?.rq.copyWith(
                                color: const Color(0xffC4C2C2),
                                height: 1.25,
                              ),
                            ),
                          ],
                        ),
                        3.verticalSpace,
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          28.verticalSpace,
          Form(
            key: _formkey,
            child: Padding(
              padding: HWEdgeInsets.symmetric(horizontal: 20.0),
              child: ValueListenableBuilder<bool>(
                valueListenable: displaySubmit,
                builder: (context, display, _) {
                  return NameFormField(
                    onFieldSubmitted: (val) {
                      if (display) {
                        if (!widget.fromLogin) {
                          // BlocProvider.of<AuthBloc>(context)
                          //     .add(VerifyOtpSignUpEvent(
                          //   name: form.controllers[0].text,
                          //   otp: prefsRepository.otpCode!,
                          //   verificationId:
                          //       prefsRepository.verificationId!,
                          // ));
                        } else {}
                        ////////////////
                        // FirebaseAnalyticsService.logEventForSession(
                        //   eventName: AnalyticsEventsConst.buttonClicked,
                        //   executedEventName:
                        //       AnalyticsButtonsEventNameConst
                        //           .confirmNameButton,
                        // );
                      }
                    },
                    key: TestVariables.kTestMode
                        ? const Key(WidgetsKeys.nameFormFieldKey)
                        : null,
                    validator: ((value) {
                      if (value!.length < 8) {
                        return LocaleKeys.must_be_at_least_8_characters.tr();
                      }
                      return null;
                    }),
                    ready: display,
                    onChange: (String? text) {
                      _formkey.currentState!.validate();

                      displaySubmit.value = text!.length >= 8;
                    },
                    controller: form.controllers[0],
                    suffixIcon: Padding(
                      padding: HWEdgeInsets.only(right: 20.0, top: 22),
                      child: !display
                          ? const SizedBox(width: 22, height: 15)
                          : InkWell(
                              key: TestVariables.kTestMode
                                  ? const Key(WidgetsKeys.confirmNameButtonKey)
                                  : null,
                              onTap: () {
                                if (!widget.fromLogin) {
                                  // BlocProvider.of<AuthBloc>(context)
                                  //     .add(VerifyOtpSignUpEvent(
                                  //   name: form.controllers[0].text,
                                  //   otp: prefsRepository.otpCode!,
                                  //   verificationId:
                                  //       prefsRepository.verificationId!,
                                  // ));
                                } else {}
                                ////////////////
                                // FirebaseAnalyticsService
                                //     .logEventForSession(
                                //   eventName:
                                //       AnalyticsEventsConst.buttonClicked,
                                //   executedEventName:
                                //       AnalyticsButtonsEventNameConst
                                //           .confirmNameButton,
                                // );
                              },
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  updateNameLoading
                                      ? CircularProgressIndicator()
                                      : SvgPicture.asset(
                                          AppAssets.submitArrowSvg,
                                          width: 10,
                                          height: 20,
                                        ),
                                ],
                              ),
                            ),
                    ),
                  );
                },
              ),
            ),
          ),
          120.verticalSpace,
        ],
      ),
    );
  }

  @override
  int get numberOfFields => 1;
}
 */
