import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:rdb/theme/typography.dart';
import 'package:shimmer/shimmer.dart';
import 'package:rdb/common/test_utils/test_var.dart';
import 'package:rdb/core/utils/extensions/build_context.dart';
import 'package:rdb/generated/locale_keys.g.dart';
import 'package:rdb/core/utils/last_pages_tracker.dart';
import '../../../../base_page.dart';
import '../../../../common/constant/design/assets_provider.dart';
import '../../../../common/test_utils/widgets_keys.dart';
import '../../../../core/domin/repositories/prefs_repository.dart';
import '../../../../core/utils/responsive_padding.dart';
import '../../../../core/utils/theme_state.dart';
import '../../../../routes/router.dart';
import '../../../app/my_text_widget.dart';
import '../manager/auth_bloc.dart';

class AlreadyExistAccount extends StatefulWidget {
  const AlreadyExistAccount({required this.phoneNumber, super.key});
  final String phoneNumber;
  @override
  State<AlreadyExistAccount> createState() => _AlreadyExistAccountState();
}

class _AlreadyExistAccountState extends ThemeState<AlreadyExistAccount> {
  PrefsRepository prefsRepository = GetIt.I<PrefsRepository>();

  @override
  void didChangeDependencies() {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Color(0xffF4F8FF),
        statusBarBrightness: Brightness.light,
        statusBarIconBrightness: Brightness.dark,
      ),
    );

    super.didChangeDependencies();
  }

  @override
  void initState() {
    LastPagesTracker.push('AlreadyExistAccount');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    FlutterError.onError = (FlutterErrorDetails error) {
      LastPagesTracker.sendErrorToBlocAndLog(error);
      FlutterError.dumpErrorToConsole(error);
    };
    bool verifiedBySignIn = false;
    return Scaffold(
      backgroundColor: const Color(0xffF4F8FF),
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Positioned(top: 50, left: 40, right: 40, child: logo),
          Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              Padding(
                padding: HWEdgeInsets.symmetric(horizontal: 40.0),
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SvgPicture.asset(
                          AppAssets.registerInfoSvg,
                          width: 15,
                          height: 15,
                          // ignore: deprecated_member_use
                          color: const Color(0xff388CFF),
                        ),
                        10.horizontalSpace,
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            MyTextWidget(
                              LocaleKeys.this_numbber_already.tr(),
                              style: context.textTheme.titleLarge?.rq.copyWith(
                                color: const Color(0xff5D5C5D),
                                height: 1.42,
                              ),
                            ),
                            Row(
                              children: [
                                Padding(
                                  padding: HWEdgeInsets.only(top: 3.0),
                                  child: SvgPicture.asset(
                                    AppAssets.phoneCallSvg,
                                    width: 10,
                                    height: 10,
                                  ),
                                ),
                                5.horizontalSpace,
                                MyTextWidget(
                                  widget.phoneNumber,
                                  textAlign: TextAlign.start,
                                  style: context.textTheme.titleMedium?.rq
                                      .copyWith(
                                        color: const Color(0xff8D8D8D),
                                        height: 1.25,
                                      ),
                                ),
                              ],
                            ),
                            10.verticalSpace,
                            Row(
                              children: [
                                15.horizontalSpace,
                                MyTextWidget(
                                  LocaleKeys.you_can_login_now.tr(),
                                  style: context.textTheme.titleMedium?.rq
                                      .copyWith(
                                        color: const Color(0xffC4C2C2),
                                        height: 1.25,
                                      ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Spacer(),
              BlocBuilder<AuthBloc, AuthState>(
                buildWhen: (previous, current) =>
                    previous.verifyOtpSignInStatus !=
                    current.verifyOtpSignInStatus,
                builder: (context, state) {
                  if (state.verifyOtpSignInStatus ==
                          VerifyOtpSignInStatus.success &&
                      verifiedBySignIn) {
                    verifiedBySignIn = false;
                    Future.delayed(const Duration(seconds: 2), () {
                      // ignore: use_build_context_synchronously
                      context.go(
                        '${GRouter.config.applicationRoutes.kRegistrationCompletedPage}?userName=${prefsRepository.userName}',
                      );
                    });
                  }
                  return InkWell(
                    key: TestVariables.kTestMode
                        ? const Key(WidgetsKeys.loginContinueButtonKey)
                        : null,
                    onTap: () {
                      BlocProvider.of<AuthBloc>(context).add(
                        VerifyOtpSignInEvent(
                          otp: prefsRepository.otpCode!,
                          sessionInfo: prefsRepository.sessionInfo!,
                          phone: widget.phoneNumber,
                        ),
                      );
                      verifiedBySignIn = true;
                      ////////////////////

                      //////////////////////
                      debugPrint(
                        '////////// loginContinueButton  ///////////////',
                      );
                    },
                    child:
                        state.verifyOtpSignInStatus ==
                            VerifyOtpSignInStatus.loading
                        ? Shimmer.fromColors(
                            baseColor: Colors.grey[200]!,
                            highlightColor: Colors.grey[100]!,
                            child: Container(
                              width: 1.sw,
                              height: 60,
                              margin: HWEdgeInsets.symmetric(horizontal: 20),
                              decoration: BoxDecoration(
                                color: const Color(0xffFAFAFA),
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                            ),
                          )
                        : Container(
                            width: 1.sw,
                            height: 60,
                            margin: HWEdgeInsets.symmetric(horizontal: 20),
                            decoration: BoxDecoration(
                              color: const Color(0xffFAFAFA),
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                MyTextWidget(
                                  LocaleKeys.login_continue.tr(),
                                  style: textTheme.displayMedium?.rq.copyWith(
                                    color: const Color(0xff5D5C5D),
                                    letterSpacing: 0.16,
                                    height: 1.25,
                                  ),
                                ),
                              ],
                            ),
                          ),
                  );
                },
              ),
              20.verticalSpace,
            ],
          ),
        ],
      ),
    );
  }
}
