import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:rdb/core/domin/repositories/prefs_repository.dart';
import 'package:rdb/core/utils/extensions/build_context.dart';
import 'package:rdb/core/utils/form_state_mixin.dart';
import 'package:rdb/core/utils/form_utils.dart';
import 'package:rdb/features/authentication/presentation/widgets/pin_item.dart';
import 'package:rdb/routes/router.dart';
import 'package:rdb/theme/typography.dart';
import 'package:rdb/generated/locale_keys.g.dart';
import 'dart:ui' as ui;

enum PinCodeState { set, confirm, verify, done }

class PinCodePage extends StatefulWidget {
  const PinCodePage({super.key});

  @override
  State<PinCodePage> createState() => _PinCodePageState();
}

class _PinCodePageState extends State<PinCodePage> with FormStateMinxin {
  final PrefsRepository prefsRepository = GetIt.I<PrefsRepository>();
  late PinCodeState _state;
  String _firstPin = '';
  int codeStatus = 0; // 0: idle, 1: success, 2: error
  late final ValueNotifier<int> checkOtp;
  bool isExpired = false;

  @override
  void initState() {
    checkOtp = ValueNotifier<int>(0);
    final storedPin = prefsRepository.passcode;
    if (storedPin == null || storedPin.isEmpty) {
      _state = PinCodeState.set;
    } else {
      _state = PinCodeState.verify;
    }
    super.initState();
  }

  void _clearRotation() {
    for (var controller in form.controllers) {
      controller.text = '\u200b';
    }
    resetPinGlobalState();
  }

  String _getEnteredPin() {
    return form.controllers.map((c) => c.text.replaceAll('\u200b', '')).join();
  }

  void _handlePinComplete() async {
    final inputPin = _getEnteredPin();
    if (inputPin.length < numberOfFields) return;

    switch (_state) {
      case PinCodeState.set:
        setState(() {
          _firstPin = inputPin;
          _state = PinCodeState.confirm;
          codeStatus = 0;
          _clearRotation();
        });
        break;
      case PinCodeState.confirm:
        if (inputPin == _firstPin) {
          await prefsRepository.setPasscode(inputPin);
          setState(() {
            _state = PinCodeState.done;
            codeStatus = 1;
          });
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) {
              prefsRepository.setShouldShowPin(false);
              context.go(GRouter.config.applicationRoutes.kBasePage);
            }
          });
        } else {
          setState(() {
            codeStatus = 2;
          });
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) {
              setState(() {
                codeStatus = 0;
                _clearRotation();
              });
            }
          });
        }
        break;
      case PinCodeState.verify:
        if (inputPin == prefsRepository.passcode) {
          setState(() {
            codeStatus = 1;
          });
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) {
              prefsRepository.setShouldShowPin(false);
              context.go(GRouter.config.applicationRoutes.kBasePage);
            }
          });
        } else {
          setState(() {
            codeStatus = 2;
          });
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) {
              setState(() {
                codeStatus = 0;
                _clearRotation();
              });
            }
          });
        }
        break;
      case PinCodeState.done:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    String title = '';
    String subtitle = LocaleKeys.last_step.tr();
    String label = '';

    switch (_state) {
      case PinCodeState.set:
        title = LocaleKeys.set_passcode.tr();
        label = LocaleKeys.set_passcode.tr();
        break;
      case PinCodeState.confirm:
        title = LocaleKeys.set_passcode.tr();
        label = LocaleKeys.reenter_passcode.tr();
        break;
      case PinCodeState.verify:
        title = LocaleKeys.enter_passcode.tr();
        label = LocaleKeys.enter_passcode.tr();
        break;
      case PinCodeState.done:
        title = LocaleKeys.set_passcode_done.tr();
        label = LocaleKeys.set_passcode.tr();
        break;
    }

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: const Color(0xffF4FFF4),
      body: PopScope(
        canPop: _state == PinCodeState.set,
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) return;

          if (_state == PinCodeState.confirm) {
            setState(() {
              _state = PinCodeState.set;
              _firstPin = '';
              codeStatus = 0;
              _clearRotation();
            });
          }
        },
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.only(
              left: 20.h,
              right: 20.h,
              bottom: MediaQuery.of(context).viewInsets.bottom + 20.h,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 288.h),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 20.h),
                  child: Text(
                    title,
                    style: context.textTheme.titleLarge?.bq.copyWith(
                      color: const Color(0xff1D1D1D),
                      height: 1.42,
                      fontSize: 30.sp,
                    ),
                  ),
                ),
                SizedBox(height: 10.h),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 20.h),
                  child: Text(
                    subtitle,
                    style: context.textTheme.titleLarge?.mq.copyWith(
                      color: const Color(0xff1D1D1D),
                      height: 1.42,
                      fontSize: 16.sp,
                    ),
                  ),
                ),

                SizedBox(height: 130.h),
                _buildPinSlot(),
                SizedBox(height: 10.h),
                Center(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.black45,
                      fontFamily: 'SF-Pro-Text-Regular',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPinSlot() {
    return Directionality(
      textDirection: ui.TextDirection.ltr,
      child: SizedBox(
        height: 60.w,
        width: double.infinity,
        child: Row(
          textDirection: ui.TextDirection.ltr,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            PinItem(
              key: const Key('otp_item_1'),
              borderColor: codeStatus == 1
                  ? const Color(0xff78D97F)
                  : codeStatus == 2
                  ? const Color(0xffFF5F61)
                  : const Color(0xff4D84FF),
              isExpired: isExpired,
              contentColor: codeStatus == 1
                  ? const Color(0xffF4FFF4)
                  : codeStatus == 2
                  ? const Color(0xffFDF5F5)
                  : const Color(0xffFAFAFA),
              controller: form.controllers[0],
              wrongCode: codeStatus == 2,
              fromPasscose: true,
              verfySucessful: codeStatus == 1,
              index: 0,
              pasteOtpCode: pasteOtpCode,
              onChange: () {
                setState(() {
                  codeStatus = 0;
                });
              },
              autoFocus: true,
            ),
            PinItem(
              key: const Key('otp_item_2'),
              borderColor: codeStatus == 1
                  ? const Color(0xff78D97F)
                  : codeStatus == 2
                  ? const Color(0xffFF5F61)
                  : const Color(0xff4D84FF),
              verfySucessful: codeStatus == 1,
              contentColor: codeStatus == 1
                  ? const Color(0xffF4FFF4)
                  : codeStatus == 2
                  ? const Color(0xffFDF5F5)
                  : const Color(0xffFAFAFA),
              fromPasscose: true,
              isExpired: isExpired,
              controller: form.controllers[1],
              wrongCode: codeStatus == 2,
              index: 1,
              onChange: () {
                setState(() {
                  codeStatus = 0;
                });
              },
              autoFocus: false,
            ),
            PinItem(
              key: const Key('otp_item_3'),
              borderColor: codeStatus == 1
                  ? const Color(0xff78D97F)
                  : codeStatus == 2
                  ? const Color(0xffFF5F61)
                  : const Color(0xff4D84FF),
              verfySucessful: codeStatus == 1,
              fromPasscose: true,
              isExpired: isExpired,
              contentColor: codeStatus == 1
                  ? const Color(0xffF4FFF4)
                  : codeStatus == 2
                  ? const Color(0xffFDF5F5)
                  : const Color(0xffFAFAFA),
              index: 2,
              wrongCode: codeStatus == 2,
              onChange: () {
                setState(() {
                  codeStatus = 0;
                });
              },
              controller: form.controllers[2],
              autoFocus: false,
            ),
            PinItem(
              key: const Key('otp_item_4'),
              borderColor: codeStatus == 1
                  ? const Color(0xff78D97F)
                  : codeStatus == 2
                  ? const Color(0xffFF5F61)
                  : const Color(0xff4D84FF),
              verfySucessful: codeStatus == 1,
              fromPasscose: true,
              isExpired: isExpired,
              contentColor: codeStatus == 1
                  ? const Color(0xffF4FFF4)
                  : codeStatus == 2
                  ? const Color(0xffFDF5F5)
                  : const Color(0xffFAFAFA),
              index: 3,
              wrongCode: codeStatus == 2,
              onChange: () {
                setState(() {
                  codeStatus = 0;
                });
              },
              controller: form.controllers[3],
              autoFocus: false,
            ),
            PinItem(
              key: const Key('otp_item_5'),
              borderColor: codeStatus == 1
                  ? const Color(0xff78D97F)
                  : codeStatus == 2
                  ? const Color(0xffFF5F61)
                  : const Color(0xff4D84FF),
              verfySucessful: codeStatus == 1,
              fromPasscose: true,
              contentColor: codeStatus == 1
                  ? const Color(0xffF4FFF4)
                  : codeStatus == 2
                  ? const Color(0xffFDF5F5)
                  : const Color(0xffFAFAFA),
              isExpired: isExpired,
              index: 4,
              wrongCode: codeStatus == 2,
              onChange: () {
                setState(() {
                  codeStatus = 0;
                });
              },
              controller: form.controllers[4],
              autoFocus: false,
            ),
            PinItem(
              key: const Key('otp_item_6'),
              borderColor: codeStatus == 1
                  ? const Color(0xff78D97F)
                  : codeStatus == 2
                  ? const Color(0xffFF5F61)
                  : const Color(0xff4D84FF),
              verfySucessful: codeStatus == 1,
              fromPasscose: true,
              isExpired: isExpired,
              contentColor: codeStatus == 1
                  ? const Color(0xffF4FFF4)
                  : codeStatus == 2
                  ? const Color(0xffFDF5F5)
                  : const Color(0xffFAFAFA),
              index: 5,
              wrongCode: codeStatus == 2,
              onChange: () {
                setState(() {
                  codeStatus = 0;
                });
              },
              checkOtp: _handlePinComplete,
              controller: form.controllers[5],
              autoFocus: false,
            ),
          ],
        ),
      ),
    );
  }

  void pasteOtpCode(String text) {
    if (text.length != 6) return;
    for (int i = 0; i < 6; i++) {
      form.controllers[i].text = text[i];
    }
    _handlePinComplete();
  }

  @override
  int get numberOfFields => 6;
}
