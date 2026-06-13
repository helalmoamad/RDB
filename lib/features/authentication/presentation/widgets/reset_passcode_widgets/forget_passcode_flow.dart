import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get_it/get_it.dart';
import 'package:rdb/common/constant/design/assets_provider.dart';
import 'package:rdb/common/helper/show_message.dart';
import 'package:rdb/features/authentication/presentation/manager/auth_bloc.dart';
import 'forget_passcode_intro.dart';
import 'reset_phone_tab.dart';
import 'reset_pin_item.dart';
import 'reset_questions_view.dart';
import 'reset_result_pages.dart';
import 'reset_setup_passcode_page.dart';
import 'reset_verification_methods.dart';
import 'reset_verify_otp.dart';

/// تدفّق "Forget Passcode" المستقلّ على شكل PageView مع زرّ X في الأعلى للرجوع.
/// يُفتح من نص "Forget Passcode ?" داخل صفحة التحقق من رمز المرور.
///
/// التدفّق مدفوع بالباك عبر [AuthBloc]:
///  مقدّمة → (init) → [قفل / وجه / أسئلة]. وفي idle-lock غير الموثّق:
///  هاتف → طريقة (send-otp) → OTP (verify-otp) → أسئلة → answers →
///  [passcode جديد (complete) / فشل / قفل].
class ForgetPasscodeFlow extends StatefulWidget {
  const ForgetPasscodeFlow({this.midLogin = false, super.key});

  /// عند `true` (الدخول من خطوة passcode أثناء تسجيل الدخول): نتخطّى الهاتف
  /// والطرق والـ OTP ونذهب من المقدّمة مباشرةً للأسئلة (مجموعة step/* في الباك).
  final bool midLogin;

  @override
  State<ForgetPasscodeFlow> createState() => _ForgetPasscodeFlowState();
}

class _ForgetPasscodeFlowState extends State<ForgetPasscodeFlow> {
  final PageController _pageController = PageController();
  final ValueNotifier<int> _currentPage = ValueNotifier<int>(0);
  final FocusNode _phoneFocus = FocusNode(debugLabel: 'resetPhone');

  // AuthBloc المشترك (مفرد) — نعتمد عليه لعمليات إعادة التعيين. لا نُغلقه.
  final AuthBloc _bloc = GetIt.I<AuthBloc>();

  // مفتاح حاوية الأسئلة لتفويض زرّ X إليها (رجوع سؤال أو الخروج من السؤال الأول).
  final GlobalKey<ResetQuestionsViewState> _questionsKey =
      GlobalKey<ResetQuestionsViewState>();

  String _phoneNumber = '';
  int _isViaWhatsApp = 0;

  @override
  void initState() {
    super.initState();
    // تصفير أي حالة reset قديمة عالقة (AuthBloc مفرد) قبل بدء تدفّق جديد.
    _bloc.add(const ResetFlowClearEvent());
  }

  // ─ فهارس الصفحات ─
  // شاشة passcode الجديد ليست هنا؛ نُنتقل إليها كصفحة منفصلة (pushReplacement).
  static const int _questionsPage = 4;
  static const int _failurePage = 5;
  static const int _lockedPage = 6;
  static const int _facePage = 7;

  /// مستمع نتائج AuthBloc — يقود تنقّل التدفّق حسب ردود الباك.
  void _onResetState(BuildContext context, AuthState s) {
    // 0) فشل init أو questions → رسالة ثم الخروج. في mid-login يعني غالباً
    // انتهاء stepToken (401)، فيعود المستخدم لخطوة الدخول لإعادة المحاولة.
    // (حُرّاس الصفحة تتجنّب الخروج بسبب حالة فشل قديمة عالقة في الـ singleton.)
    if (s.resetInitStatus == ResetInitStatus.failure &&
        _currentPage.value == 0) {
      _showErrorAndClose(s.resetError);
      return;
    }
    // فشل questions يحدث ونحن على المقدّمة (mid-login) أو على OTP (idle-lock).
    if (s.resetQuestionsStatus == ResetQuestionsStatus.failure &&
        (_currentPage.value == 0 || _currentPage.value == 3)) {
      _showErrorAndClose(s.resetError);
      return;
    }
    // 1) تفرّع init (ونحن على المقدّمة).
    if (s.resetInitStatus == ResetInitStatus.success &&
        _currentPage.value == 0 &&
        s.resetInitResult != null) {
      final r = s.resetInitResult!;
      if (r.isLocked) {
        _jumpToPage(_lockedPage);
      } else if (r.needsFace) {
        // فرع الوجه (مستخدم موثّق على idle-lock) — التقاط الوجه لاحقاً.
        _jumpToPage(_facePage);
      } else if (widget.midLogin) {
        // mid-login: نطلب الأسئلة ونبقى على المقدّمة (زرّ Start يبقى shimmer)
        // حتى تجهز، ثم ننتقل (الفرع أدناه).
        _bloc.add(ResetQuestionsEvent(midLogin: widget.midLogin));
      } else {
        _goToPage(1); // idle-lock غير موثّق: هاتف → طرق → OTP → أسئلة.
      }
      return;
    }
    // 1.b) جهوز الأسئلة → ننتقل لصفحتها (من المقدّمة mid-login أو من OTP).
    if (s.resetQuestionsStatus == ResetQuestionsStatus.success &&
        (_currentPage.value == 0 || _currentPage.value == 3)) {
      _jumpToPage(_questionsPage);
      return;
    }
    // 2) نتيجة الإجابات (ونحن على صفحة الأسئلة).
    if (s.resetAnswersStatus == ResetAnswersStatus.success &&
        _currentPage.value == _questionsPage) {
      final token = s.resetToken ?? '';
      final locked = s.resetLockedUntil ?? '';
      if (token.isNotEmpty) {
        // كل الإجابات صحيحة → ننتقل لشاشة تعيين الرمز الجديد (دون رجوع).
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => ResetSetupPasscodePage(midLogin: widget.midLogin),
          ),
        );
      } else if (locked.isNotEmpty) {
        _jumpToPage(_lockedPage); // نفدت المحاولات → قفل.
      } else {
        _goToPage(_failurePage); // خطأ مع بقاء محاولات → أعد المحاولة.
      }
      return;
    }
  }

  /// يعرض رسالة خطأ ويُغلق التدفّق (يعود لشاشة إدخال الـ passcode).
  void _showErrorAndClose(String? msg) {
    showMessage(
      (msg == null || msg.isEmpty)
          ? 'تعذّر إكمال العملية، حاول مجدداً'
          : msg,
      hasError: true,
      showInRelease: true,
    );
    Navigator.of(context).pop();
  }

  /// انتقال فوري بلا أنيميشن (للقفزات البعيدة).
  void _jumpToPage(int index) {
    _currentPage.value = index;
    _pageController.jumpToPage(index);
  }

  void _goToPage(int index) {
    _currentPage.value = index;
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  /// زرّ X / الرجوع. على صفحة الأسئلة يُفوَّض للحاوية (رجوع سؤال)، ومن السؤال
  /// الأول أو صفحات النتيجة/المقدّمة يخرج من كل التدفّق.
  void _onClose() {
    final p = _currentPage.value;
    if (p == _questionsPage) {
      if (_questionsKey.currentState?.handleBack() ?? false) return;
      Navigator.of(context).pop();
      return;
    }
    if (p == 0 ||
        p == _failurePage ||
        p == _lockedPage ||
        p == _facePage) {
      Navigator.of(context).pop();
    } else {
      _goToPage(p - 1);
    }
  }

  /// تنسيق وقت القفل المتبقّي (HH:MM) من lockedUntil أو عدد الساعات.
  String _formatLockout(AuthState s) {
    final until = s.resetLockedUntil ?? '';
    if (until.isNotEmpty) {
      final dt = DateTime.tryParse(until);
      if (dt != null) {
        final diff = dt.difference(DateTime.now());
        if (diff.inMinutes > 0) {
          final h = diff.inHours;
          final m = diff.inMinutes % 60;
          return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';
        }
      }
    }
    final hrs = s.resetLockoutHours ?? 0;
    return '${hrs.toString().padLeft(2, '0')}:00';
  }

  @override
  void dispose() {
    // لا نُغلق _bloc لأنه AuthBloc المشترك (مفرد).
    _pageController.dispose();
    _currentPage.dispose();
    _phoneFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AuthBloc>.value(
      value: _bloc,
      child: BlocListener<AuthBloc, AuthState>(
        listenWhen: (p, c) =>
            p.resetInitStatus != c.resetInitStatus ||
            p.resetQuestionsStatus != c.resetQuestionsStatus ||
            p.resetAnswersStatus != c.resetAnswersStatus,
        listener: _onResetState,
        child: _buildScaffold(context),
      ),
    );
  }

  Widget _buildScaffold(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        _onClose();
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        resizeToAvoidBottomInset: false,
        body: SafeArea(
          child: Stack(
            children: [
              // مسافة علوية ثابتة موحّدة لكل الصفحات.
              Column(
                children: [
                  SizedBox(height: 250.h),
                  Expanded(
                    child: PageView(
                      controller: _pageController,
                      physics: const NeverScrollableScrollPhysics(),
                      onPageChanged: (i) {
                        _currentPage.value = i;
                        if (i == 3) {
                          resetRequestOtpKeyboard();
                        } else if (i != 1) {
                          FocusManager.instance.primaryFocus?.unfocus();
                        }
                      },
                      children: [
                        // 0) المقدّمة — Start يطلق init؛ الزرّ يصبح shimmer أثناء
                        // init (و questions في mid-login) ثم ننتقل عند الجهوز.
                        BlocBuilder<AuthBloc, AuthState>(
                          buildWhen: (p, c) =>
                              p.resetInitStatus != c.resetInitStatus ||
                              p.resetQuestionsStatus != c.resetQuestionsStatus,
                          builder: (context, s) => ForgetPasscodeIntro(
                            isLoading:
                                s.resetInitStatus == ResetInitStatus.loading ||
                                s.resetQuestionsStatus ==
                                    ResetQuestionsStatus.loading,
                            onStart: () => _bloc.add(
                              ResetInitEvent(midLogin: widget.midLogin),
                            ),
                          ),
                        ),
                        // 1) إدخال رقم الهاتف.
                        SingleChildScrollView(
                          child: ResetPhoneTab(
                            focusNode: _phoneFocus,
                            moveToNextStep: (phone) {
                              setState(
                                () => _phoneNumber = phone.replaceAll(' ', ''),
                              );
                              _goToPage(2);
                            },
                          ),
                        ),
                        // 2) اختيار طريقة الإرسال (send-otp). الانتقال للـ OTP
                        // يحدث عند نجاح الإرسال (داخل الصفحة عبر resetSendOtpStatus).
                        SingleChildScrollView(
                          child: ResetVerificationMethods(
                            phoneNumber: _phoneNumber,
                            goBackToPhone: () => _goToPage(1),
                            onChooseWhatsapp: () {
                              setState(() => _isViaWhatsApp = 1);
                              _goToPage(3);
                            },
                            onChooseSms: () {
                              setState(() => _isViaWhatsApp = 0);
                              _goToPage(3);
                            },
                          ),
                        ),
                        // 3) التحقق من OTP — عند النجاح نطلب الأسئلة ثم ننتقل.
                        SingleChildScrollView(
                          child: ResetVerifyOtp(
                            phoneNumber: _phoneNumber,
                            isViaWhatsApp: _isViaWhatsApp,
                            onVerified: () {
                              // نطلب الأسئلة فقط؛ ننتقل بعد جهوزها (المستمع).
                              _bloc.add(
                                ResetQuestionsEvent(midLogin: widget.midLogin),
                              );
                            },
                            goBack: () => _goToPage(2),
                          ),
                        ),
                        // 4) حاوية الأسئلة الديناميكية (عددها ونصوصها من الباك).
                        BlocBuilder<AuthBloc, AuthState>(
                          buildWhen: (p, c) =>
                              p.resetQuestions != c.resetQuestions,
                          builder: (context, s) {
                            if (s.resetQuestions.isEmpty) {
                              // لا نصل هنا عادةً (ننتقل بعد جهوز الأسئلة).
                              return const SizedBox.shrink();
                            }
                            return ResetQuestionsView(
                              key: _questionsKey,
                              questions: s.resetQuestions,
                              onSubmit: (answers) => _bloc.add(
                                ResetAnswersEvent(
                                  answers: answers,
                                  midLogin: widget.midLogin,
                                ),
                              ),
                            );
                          },
                        ),
                        // 5) صفحة الفشل — تعرض المحاولات المتبقّية، و"أعد
                        // المحاولة" تعيد الأسئلة من جديد.
                        BlocBuilder<AuthBloc, AuthState>(
                          buildWhen: (p, c) =>
                              p.resetAttemptsRemaining !=
                              c.resetAttemptsRemaining,
                          builder: (context, s) => ResetTryAgainPage(
                            attemptsRemaining: s.resetAttemptsRemaining,
                            onTryAgain: () {
                              _questionsKey.currentState?.reset();
                              _bloc.add(
                                ResetQuestionsEvent(midLogin: widget.midLogin),
                              );
                              _jumpToPage(_questionsPage);
                            },
                          ),
                        ),
                        // 6) صفحة القفل — وقتها من lockedUntil/الساعات.
                        BlocBuilder<AuthBloc, AuthState>(
                          buildWhen: (p, c) =>
                              p.resetLockedUntil != c.resetLockedUntil ||
                              p.resetLockoutHours != c.resetLockoutHours,
                          builder: (context, s) =>
                              ResetLockedPage(retryAfter: _formatLockout(s)),
                        ),
                        // 7) فرع الوجه — عنصر نائب (لاحقاً).
                        const _FacePlaceholder(),
                      ],
                    ),
                  ),
                ],
              ),
              // زرّ الإغلاق X أعلى اليمين.
              Positioned(
                top: 16.h,
                right: 20.w,
                child: InkWell(
                  onTap: _onClose,
                  borderRadius: BorderRadius.circular(20.r),
                  child: Padding(
                    padding: EdgeInsets.all(8.w),
                    child: SvgPicture.asset(AppAssets.cancelSvg, height: 15.h),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// عنصر نائب لفرع الوجه (مستخدم موثّق على idle-lock). التقاط الوجه سيُضاف لاحقاً.
class _FacePlaceholder extends StatelessWidget {
  const _FacePlaceholder();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 40.w),
        child: Text(
          'التحقق بالوجه — قيد الإنشاء',
          textAlign: TextAlign.center,
          style: TextStyle(color: const Color(0xff5D5C5D), fontSize: 16.sp),
        ),
      ),
    );
  }
}
