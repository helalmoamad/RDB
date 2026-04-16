import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:rdb/core/utils/extensions/build_context.dart';
import 'package:rdb/theme/typography.dart';
import '../../../../core/utils/responsive_padding.dart';
import '../../../../core/utils/theme_state.dart';
import '../../../../routes/router.dart';
import '../../../app/my_text_widget.dart';
import 'package:rdb/core/utils/last_pages_tracker.dart';

class LoginSuccessfully extends StatefulWidget {
  const LoginSuccessfully({required this.phoneNumber, super.key});
  final String phoneNumber;

  @override
  State<LoginSuccessfully> createState() => _LoginSuccessfullyState();
}

class _LoginSuccessfullyState extends ThemeState<LoginSuccessfully> {
  @override
  void didChangeDependencies() async {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Color(0xffE0FFEE),
        statusBarBrightness: Brightness.light,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) context.go(GRouter.config.applicationRoutes.kBasePage);
    });
    super.didChangeDependencies();
  }

  @override
  void initState() {
    LastPagesTracker.push('LoginSuccessfully');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    FlutterError.onError = (FlutterErrorDetails error) {
      LastPagesTracker.sendErrorToBlocAndLog(error);
      FlutterError.dumpErrorToConsole(error);
    };
    return SafeArea(
      bottom: false,
      left: false,
      right: false,

      child: Scaffold(
        backgroundColor: const Color(0xffE0FFEE),
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
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(height: 300.h),
                  Padding(
                    padding: HWEdgeInsets.symmetric(horizontal: 40.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        MyTextWidget(
                          "Sign Up Successfully !",
                          textAlign: TextAlign.start,
                          style: context.textTheme.titleMedium?.mq.copyWith(
                            color: const Color(0xff1D1D1D),
                            height: 1.25,
                            fontSize: 30.sp,
                          ),
                        ),
                        10.verticalSpace,
                        MyTextWidget(
                          "Enjoy With Our Services",
                          textAlign: TextAlign.start,
                          style: context.textTheme.titleMedium?.mq.copyWith(
                            color: const Color(0xff1D1D1D),
                            height: 1.25,
                            fontSize: 16.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                ],
              ),
            ),
      ),
    );
  }
}
