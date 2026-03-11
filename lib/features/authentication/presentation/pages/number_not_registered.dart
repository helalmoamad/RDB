import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:rdb/common/test_utils/test_var.dart';
import 'package:rdb/core/domin/repositories/prefs_repository.dart';
import 'package:rdb/core/utils/extensions/build_context.dart';
import 'package:rdb/generated/locale_keys.g.dart';
import 'package:rdb/routes/router.dart';
import 'package:rdb/theme/typography.dart';
import '../../../../base_page.dart';
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
  @override
  void didChangeDependencies() async {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Color(0xffFFF9F0),
        statusBarBrightness: Brightness.light,
        statusBarIconBrightness: Brightness.dark,
      ),
    );

    super.didChangeDependencies();
  }

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
                  if (pageController.page == 1) {
                    prefsRepository.setUserName("");
                    context.go(
                      '${GRouter.config.applicationRoutes.kRegistrationCompletedPage}?userName=',
                    );
                    return false;
                  }
                  return true;
                },
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    Positioned(top: 50, left: 40, right: 40, child: logo),
                    PageView(
                      physics: const NeverScrollableScrollPhysics(),
                      controller: pageController,
                      children: [
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SvgPicture.asset(
                                        AppAssets.registerInfoSvg,
                                        width: 15,
                                        height: 15,
                                        // ignore: deprecated_member_use
                                        color: const Color(0xffFCAC2D),
                                      ),
                                      10.horizontalSpace,
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          MyTextWidget(
                                            LocaleKeys
                                                .sorry_this_number_is_not_registered_with_us
                                                .tr(),
                                            style: context
                                                .textTheme
                                                .titleLarge
                                                ?.rq
                                                .copyWith(
                                                  color: const Color(
                                                    0xff5D5C5D,
                                                  ),
                                                  height: 1.42,
                                                ),
                                          ),
                                          Row(
                                            children: [
                                              Padding(
                                                padding: HWEdgeInsets.only(
                                                  top: 3.0,
                                                ),
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
                                                style: context
                                                    .textTheme
                                                    .titleMedium
                                                    ?.rq
                                                    .copyWith(
                                                      color: const Color(
                                                        0xff8D8D8D,
                                                      ),
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
                                                LocaleKeys
                                                    .register_create_new_account
                                                    .tr(),
                                                style: context
                                                    .textTheme
                                                    .titleMedium
                                                    ?.rq
                                                    .copyWith(
                                                      color: const Color(
                                                        0xffC4C2C2,
                                                      ),
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
                            InkWell(
                              key: TestVariables.kTestMode
                                  ? const Key(
                                      WidgetsKeys.createNewAccountContinueKey,
                                    )
                                  : null,
                              onTap: () {
                                pageContent.value = 1;
                                pageController.animateToPage(
                                  1,
                                  duration: const Duration(milliseconds: 500),
                                  curve: Curves.easeInOut,
                                );
                                ///////////////////
                              },
                              child: Container(
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
                                      LocaleKeys.create_new_account_continue
                                          .tr(),
                                      style: textTheme.displayMedium?.rq
                                          .copyWith(
                                            color: const Color(0xff5D5C5D),
                                            letterSpacing: 0.16,
                                            height: 1.25,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            20.verticalSpace,

                            const SizedBox(height: 44),
                          ],
                        ),
                        //const AddingName(fromLogin: true),
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
