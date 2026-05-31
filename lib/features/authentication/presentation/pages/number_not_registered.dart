import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:rdb/common/test_utils/test_var.dart';
import 'package:rdb/core/domin/repositories/prefs_repository.dart';
import 'package:rdb/core/utils/extensions/build_context.dart';
import 'package:rdb/features/authentication/presentation/manager/auth_bloc.dart';
import 'package:rdb/generated/locale_keys.g.dart';
import 'package:rdb/routes/router.dart';
import 'package:rdb/theme/typography.dart';
import '../../../../common/constant/design/assets_provider.dart';
import '../../../../common/test_utils/widgets_keys.dart';
import '../../../../core/utils/responsive_padding.dart';
import '../../../../core/utils/theme_state.dart';
import '../../../app/my_text_widget.dart';

class NumberNotRegistered extends StatefulWidget {
  const NumberNotRegistered({required this.phoneNumber, super.key});
  final String phoneNumber;

  @override
  State<NumberNotRegistered> createState() => _NumberNotRegisteredState();
}

class _NumberNotRegisteredState extends ThemeState<NumberNotRegistered> {
  final ValueNotifier<int> pageContent = ValueNotifier(0);
  final PageController pageController = PageController();
  PrefsRepository prefsRepository = GetIt.I<PrefsRepository>();
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: pageContent,
      builder: (context, index, _) {
        return Scaffold(
          backgroundColor: index == 0
              ? const Color(0xffFFF9F0)
              : const Color(0xffF4FFF4),
          body:
              // ignore: deprecated_member_use
              WillPopScope(
                onWillPop: () async {
                  /*  if (pageController.page == 1) {
                    prefsRepository.setUserName("");
                    context.go(
                      '${GRouter.config.applicationRoutes.kRegistrationCompletedPage}?userName=',
                    );
                    return false;
                  }*/
                  return false;
                },
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 288.h),
                        Padding(
                          padding: HWEdgeInsets.symmetric(horizontal: 40.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              MyTextWidget(
                                LocaleKeys.not_registered_exclamation.tr(),
                                style: context.textTheme.titleLarge?.bq
                                    .copyWith(
                                      color: const Color(0xff1D1D1D),
                                      height: 1.42,
                                      fontSize: 30.sp,
                                    ),
                              ),
                              10.verticalSpace,
                              MyTextWidget(
                                LocaleKeys
                                    .sorry_this_number_is_not_registered_with_us
                                    .tr(),
                                style: context.textTheme.titleLarge?.mq
                                    .copyWith(
                                      color: const Color(0xff1D1D1D),
                                      height: 1.42,
                                      fontSize: 16.sp,
                                    ),
                              ),
                              10.verticalSpace,
                              Row(
                                children: [
                                  MyTextWidget(
                                    "+ ${widget.phoneNumber}",
                                    textAlign: TextAlign.start,
                                    style: context.textTheme.titleMedium?.rq
                                        .copyWith(
                                          color: const Color(0xff1D1D1D),
                                          height: 1.25,
                                          fontSize: 12.sp,
                                        ),
                                  ),
                                  10.horizontalSpace,
                                  SvgPicture.asset(
                                    AppAssets.yallowQuestion,
                                    width: 15.w,
                                    height: 15.h,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        InkWell(
                          key: TestVariables.kTestMode
                              ? const Key(
                                  WidgetsKeys.createNewAccountContinueKey,
                                )
                              : null,
                          onTap: () {
                            GetIt.I<AuthBloc>().add(ResetAllData());
                            context.go(
                              GRouter
                                  .config
                                  .applicationRoutes
                                  .kRegistrationPage,
                            );
                          },
                          child: Container(
                            width: 1.sw,
                            height: 60.h,
                            margin: HWEdgeInsets.symmetric(horizontal: 20.w),
                            decoration: BoxDecoration(
                              color: const Color(0xffFAFAFA),
                              borderRadius: BorderRadius.circular(20.r),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                MyTextWidget(
                                  LocaleKeys.create_new_account_continue.tr(),
                                  style: textTheme.displayMedium?.rq.copyWith(
                                    color: const Color(0xff5D5C5D),
                                    letterSpacing: 0.16,
                                    height: 1.25,
                                    fontSize: 16.sp,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        30.verticalSpace,
                        Center(
                          child: MyTextWidget(
                            LocaleKeys.cancel_take_look.tr(),
                            style: textTheme.displayMedium?.rq.copyWith(
                              color: const Color(0xff4D84FF),
                              letterSpacing: 0.16,
                              height: 1.25,
                              fontSize: 14.sp,
                            ),
                          ),
                        ),
                        SizedBox(height: 54.h),
                      ],
                    ),
                  ],
                ),
              ),
        );
      },
    );
  }
}
