import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:rdb/core/domin/repositories/prefs_repository.dart';
import 'package:rdb/core/utils/extensions/build_context.dart';
import 'package:rdb/core/utils/form_state_mixin.dart';
import 'package:rdb/core/utils/form_utils.dart';
import 'package:rdb/features/authentication/presentation/manager/auth_bloc.dart';
import 'package:rdb/features/authentication/presentation/widgets/pin_item.dart';
import 'package:rdb/routes/router.dart';
import 'package:rdb/theme/typography.dart';
import 'package:rdb/generated/locale_keys.g.dart';
import 'dart:async';
import 'dart:ui' as ui;

enum PinCodeSetupState { set, confirm }

class PinCodeSetupPage extends StatefulWidget {
  const PinCodeSetupPage({super.key});

  @override
  State<PinCodeSetupPage> createState() => _PinCodeSetupPageState();
}

class _PinCodeSetupPageState extends State<PinCodeSetupPage>
    with FormStateMinxin {
  final PrefsRepository prefsRepository = GetIt.I<PrefsRepository>();
  PinCodeSetupState _state = PinCodeSetupState.set;
  String _firstPin = '';
  int codeStatus = 0; // 0: idle, 1: success, 2: error
  late final ValueNotifier<int> checkOtp;
  bool isExpired = false;

  @override
  void initState() {
    super.initState();
    checkOtp = ValueNotifier<int>(0);
  }

  void _onPinChanged() => setState(() => codeStatus = 0);

  void _clearRotation() {
    for (var controller in form.controllers) {
      controller.text = '\u200b';
    }
    resetPinGlobalState();
  }

  String _getEnteredPin() =>
      form.controllers.map((c) => c.text.replaceAll('\u200b', '')).join();

  void _handlePinComplete() async {
    final inputPin = _getEnteredPin();
    if (inputPin.length < numberOfFields) return;

    switch (_state) {
      case PinCodeSetupState.set:
        setState(() {
          _firstPin = inputPin;
          _state = PinCodeSetupState.confirm;
          codeStatus = 0;
          _clearRotation();
        });
        break;

      case PinCodeSetupState.confirm:
        if (inputPin == _firstPin) {
          setState(() => codeStatus = 1);

          GetIt.I<AuthBloc>().add(SetPasscodeEvent(inputPin));
        } else {
          setState(() => codeStatus = 2);
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) {
              setState(() {
                _state = PinCodeSetupState.set;
                _firstPin = '';
                codeStatus = 0;
                _clearRotation();
              });
            }
          });
        }
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final keyboardInset = MediaQuery.of(context).viewInsets.bottom;
    final isKeyboardOpen = keyboardInset > 0;
    final topSpace = isKeyboardOpen ? 230.h : 288.h;
    final pinSectionSpace = isKeyboardOpen ? 75.h : 130.h;

    String title = LocaleKeys.set_passcode.tr();
    String subtitle = LocaleKeys.last_step.tr();
    String label = '';

    switch (_state) {
      case PinCodeSetupState.set:
        label = LocaleKeys.set_passcode.tr();
        break;
      case PinCodeSetupState.confirm:
        label = codeStatus == 2
            ? LocaleKeys.passcode_mismatch_restart.tr()
            : LocaleKeys.reenter_passcode.tr();
        break;
    }

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: const Color(0xffF4FFF4),
      body: PopScope(
        canPop: _state == PinCodeSetupState.set,
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) return;
          if (_state == PinCodeSetupState.confirm) {
            setState(() {
              _state = PinCodeSetupState.set;
              _firstPin = '';
              codeStatus = 0;
              _clearRotation();
            });
          }
        },
        child: BlocListener<AuthBloc, AuthState>(
          listenWhen: (previous, current) =>
              previous.setPasscodeStatus != current.setPasscodeStatus,
          listener: (context, state) {
            if (state.setPasscodeStatus == SetPasscodeStatus.success) {
              Future.delayed(const Duration(milliseconds: 300), () {
                if (!mounted) return;
                // ignore: use_build_context_synchronously
                context.go(
                  GRouter.config.applicationRoutes.kPasscodeWelcomePage,
                );
              });
            } else if (state.setPasscodeStatus == SetPasscodeStatus.failure) {
              setState(() => codeStatus = 2);
              Future.delayed(const Duration(seconds: 2), () {
                if (mounted) {
                  setState(() {
                    _state = PinCodeSetupState.set;
                    _firstPin = '';
                    codeStatus = 0;
                    _clearRotation();
                  });
                }
              });
            }
          },
          child: GestureDetector(
            onHorizontalDragStart: (_state != PinCodeSetupState.set)
                ? (_) {}
                : null,
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: Padding(
                padding: EdgeInsets.only(
                  left: 20.h,
                  right: 20.h,
                  bottom: keyboardInset + 20.h,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: topSpace),
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
                    SizedBox(height: pinSectionSpace),
                    _buildPinSlot(),
                    SizedBox(height: 10.h),
                    Center(
                      child: Text(
                        label,
                        style: context.textTheme.titleLarge?.bq.copyWith(
                          fontSize: 14.sp,
                          color: Colors.black45,
                        ),
                      ),
                    ),
                    10.verticalSpace,
                  ],
                ),
              ),
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
              onChange: _onPinChanged,
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
              onChange: _onPinChanged,
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
              onChange: _onPinChanged,
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
              onChange: _onPinChanged,
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
              onChange: _onPinChanged,
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
              onChange: _onPinChanged,
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
