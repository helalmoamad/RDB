import 'dart:ui' as ui;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_it/get_it.dart';
import 'package:rdb/common/helper/show_message.dart';
import 'package:rdb/core/domin/repositories/prefs_repository.dart';
import 'package:rdb/core/utils/extensions/build_context.dart';
import 'package:rdb/features/authentication/presentation/manager/auth_bloc.dart';
import 'package:rdb/generated/locale_keys.g.dart';
import 'package:rdb/theme/typography.dart';
import 'forget_passcode_flow.dart';
import 'reset_pin_item.dart';

enum _SetupState { set, confirm }

/// نسخة طبق الأصل من PinCodeSetupPage خاصّة بتدفّق إعادة التعيين: نفس التصميم
/// (الخلفية/الخطوط/الصناديق وحالتا set→confirm) لكنها تُرسل رمز المرور الجديد عبر
/// `complete` (ResetCompleteEvent) بدل SetPasscodeEvent. يُنتقل إليها دون رجوع.
class ResetSetupPasscodePage extends StatefulWidget {
  const ResetSetupPasscodePage({required this.midLogin, super.key});

  final bool midLogin;

  @override
  State<ResetSetupPasscodePage> createState() => _ResetSetupPasscodePageState();
}

class _ResetSetupPasscodePageState extends State<ResetSetupPasscodePage> {
  static const String _zwsp = '​';
  static const int _numberOfFields = 6;

  final AuthBloc _bloc = GetIt.I<AuthBloc>();
  final List<TextEditingController> _controllers = List.generate(
    _numberOfFields,
    (_) => TextEditingController(),
  );

  _SetupState _state = _SetupState.set;
  String _firstPin = '';
  int codeStatus = 0; // 0: idle, 1: success, 2: error
  bool isExpired = false;

  @override
  void initState() {
    super.initState();

    for (final c in _controllers) {
      c.text = _zwsp;
    }
    resetUnlockOtpKeyboard();
    resetCurrentToType = 0;
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _onPinChanged() => setState(() => codeStatus = 0);

  void _clearRotation() {
    for (final c in _controllers) {
      c.text = _zwsp;
    }
    resetCurrentToType = 0;
    resetCheckingOtp = false;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) resetShowOtpKeyboard(0);
    });
  }

  String _getEnteredPin() =>
      _controllers.map((c) => c.text.replaceAll(_zwsp, '')).join();

  void _handlePinComplete() {
    final inputPin = _getEnteredPin();
    if (inputPin.length < _numberOfFields) return;

    switch (_state) {
      case _SetupState.set:
        setState(() {
          _firstPin = inputPin;
          _state = _SetupState.confirm;
          codeStatus = 0;
          _clearRotation();
        });
        break;
      case _SetupState.confirm:
        if (inputPin == _firstPin) {
          setState(() => codeStatus = 1);
          _bloc.add(
            ResetCompleteEvent(passcode: inputPin, midLogin: widget.midLogin),
          );
        } else {
          setState(() => codeStatus = 2);
          Future.delayed(const Duration(seconds: 2), () {
            if (!mounted) return;
            setState(() {
              _state = _SetupState.set;
              _firstPin = '';
              codeStatus = 0;
              _clearRotation();
            });
          });
        }
        break;
    }
  }

  void _pasteOtpCode(String text) {
    if (text.length != _numberOfFields) return;
    for (int i = 0; i < _numberOfFields; i++) {
      _controllers[i].text = text[i];
    }
    _handlePinComplete();
  }

  void _onCompleteResult(BuildContext context, AuthState state) {
    // 401 على `complete` = انتهت صلاحية session stepToken. يُفحَص أولًا: وصلنا
    // هنا بـ pushReplacement فمات مستمع ForgetPasscodeFlow، ولولا هذا الفرع
    // لسقط 401 في `failure` العام فيعود المستخدم لشاشة passcode بتوكن ميت.
    if (state.resetSessionExpired) {
      handleResetStepSessionExpired(context);
      return;
    }
    if (state.resetCompleteStatus == ResetCompleteStatus.success) {
      GetIt.I<PrefsRepository>().setPasscode("true");
      final navigator = Navigator.of(context);
      // الدخول لم يكتمل بعد: لا ننتقل للرئيسية. نُعلم المستخدم أن الرمز حُفظ
      // ونعيده لشاشة إدخال الـ passcode ليكمل الدخول بالرمز الجديد.
      showMessage(LocaleKeys.reset_passcode_updated.tr(), showInRelease: true);
      Future.delayed(const Duration(milliseconds: 300), () {
        if (!mounted) return;
        navigator.pop();
      });
    } else if (state.resetCompleteStatus == ResetCompleteStatus.proofRejected) {
      // 403: البرهان غير صالح / منتهٍ / مُستهلَك (أحادي الاستخدام). الرمز الجديد
      // لم يُحفظ، لكن المستخدم ما زال يملك session stepToken صالحًا — فنعيده
      // لبداية التدفّق ليأخذ تحدّيًا جديدًا بدل إخراجه من العملية كلها.
      setState(() => codeStatus = 2);
      final navigator = Navigator.of(context);
      showMessage(
        LocaleKeys.reset_proof_expired_restart.tr(),
        hasError: true,
        showInRelease: true,
      );
      Future.delayed(const Duration(seconds: 1), () {
        if (!mounted) return;
        // pushReplacement عند دخول هذه الشاشة أزال التدفّق من المكدّس، فنفتح
        // تدفّقًا جديدًا (يبدأ بـ ResetFlowClearEvent) بدل pop إلى شاشة الـ passcode.
        navigator.pushReplacement(
          MaterialPageRoute(
            builder: (_) => ForgetPasscodeFlow(midLogin: widget.midLogin),
          ),
        );
      });
    } else if (state.resetCompleteStatus == ResetCompleteStatus.failure) {
      // فشل آخر (شبكة/خادم) → رسالة عامة وإغلاق الشاشة.
      setState(() => codeStatus = 2);
      final navigator = Navigator.of(context);
      showMessage(
        LocaleKeys.reset_could_not_verify.tr(),
        hasError: true,
        showInRelease: true,
      );
      Future.delayed(const Duration(seconds: 1), () {
        if (!mounted) return;
        navigator.pop();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final keyboardInset = MediaQuery.of(context).viewInsets.bottom;
    final isKeyboardOpen = keyboardInset > 0;
    final topSpace = isKeyboardOpen ? 230.h : 288.h;
    final pinSectionSpace = isKeyboardOpen ? 75.h : 130.h;

    // نصوص خاصّة بإعادة التعيين — هذه الشاشة تُستخدم لتدفّق reset فقط، لا
    // للتعيين الأولي (له PinCodeSetupPage). "الخطوة الأخيرة" لا تناسب سياق
    // إعادة تعيين رمز منسيّ.
    final String title = LocaleKeys.reset_set_new_passcode.tr();
    final String subtitle = LocaleKeys.reset_new_passcode_subtitle.tr();
    final String label = _state == _SetupState.set
        ? LocaleKeys.reset_set_new_passcode.tr()
        : codeStatus == 2
        ? LocaleKeys.reset_passcode_mismatch.tr()
        : LocaleKeys.reset_confirm_new_passcode.tr();

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: const Color(0xffF4FFF4),
      body: PopScope(
        // لا رجوع للأسئلة بعد النجاح؛ في مرحلة التأكيد نرجع لمرحلة الإدخال فقط.
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) return;
          if (_state == _SetupState.confirm) {
            setState(() {
              _state = _SetupState.set;
              _firstPin = '';
              codeStatus = 0;
              _clearRotation();
            });
          }
        },
        child: BlocListener<AuthBloc, AuthState>(
          bloc: _bloc,
          listenWhen: (p, c) =>
              p.resetCompleteStatus != c.resetCompleteStatus ||
              p.resetSessionExpired != c.resetSessionExpired,
          listener: _onCompleteResult,
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
    );
  }

  Widget _buildPinSlot() {
    Color borderColor() => codeStatus == 1
        ? const Color(0xff78D97F)
        : codeStatus == 2
        ? const Color(0xffFF5F61)
        : const Color(0xff4D84FF);
    Color contentColor() => codeStatus == 1
        ? const Color(0xffF4FFF4)
        : codeStatus == 2
        ? const Color(0xffFDF5F5)
        : const Color(0xffFAFAFA);

    return Directionality(
      textDirection: ui.TextDirection.ltr,
      child: SizedBox(
        height: 60.w,
        width: double.infinity,
        child: Row(
          textDirection: ui.TextDirection.ltr,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            for (int i = 0; i < _numberOfFields; i++)
              ResetPinItem(
                key: Key('reset_setup_item_$i'),
                borderColor: borderColor(),
                contentColor: contentColor(),
                isExpired: isExpired,
                controller: _controllers[i],
                wrongCode: codeStatus == 2,
                fromPasscose: true,
                verfySucessful: codeStatus == 1,
                index: i,
                onChange: _onPinChanged,
                autoFocus: i == 0,
                pasteOtpCode: i == 0 ? _pasteOtpCode : null,
                checkOtp: i == _numberOfFields - 1 ? _handlePinComplete : null,
              ),
          ],
        ),
      ),
    );
  }
}
