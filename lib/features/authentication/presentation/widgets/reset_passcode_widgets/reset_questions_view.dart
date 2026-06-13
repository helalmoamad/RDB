import 'dart:async';

import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:rdb/features/authentication/data/models/reset_passcode_models.dart';
import 'reset_question_page.dart';

/// حاوية الأسئلة الأمنية الديناميكية (عددها ونصوصها من الباك). تُدار داخلياً
/// عبر PageView، وتُجمع الإجابات كـ {questionId, optionId} وتُرسَل عبر [onSubmit].
/// الرجوع من السؤال الأول يُفوَّض للأب عبر [handleBack] (يرجع false).
class ResetQuestionsView extends StatefulWidget {
  const ResetQuestionsView({
    required this.questions,
    required this.onSubmit,
    super.key,
  });

  final List<ResetQuestion> questions;
  final void Function(List<Map<String, String>> answers) onSubmit;

  @override
  State<ResetQuestionsView> createState() => ResetQuestionsViewState();
}

class ResetQuestionsViewState extends State<ResetQuestionsView> {
  final PageController _pageController = PageController();
  int _current = 0;

  /// questionId → optionId
  final Map<String, String> _answers = {};

  static const int _countdownSeconds = kDebugMode ? 3 : 30;
  Timer? _submitTimer;
  Timer? _advanceTimer;
  bool _submitActive = false;
  final ValueNotifier<int> _countdown = ValueNotifier<int>(_countdownSeconds);

  bool get _allAnswered =>
      widget.questions.isNotEmpty &&
      widget.questions.every((q) => _answers.containsKey(q.id));

  /// إعادة الضبط لمحاولة جديدة (بعد الفشل): مسح الإجابات والمؤقّت والعودة لأول
  /// سؤال.
  void reset() {
    _submitTimer?.cancel();
    _advanceTimer?.cancel();
    _submitActive = false;
    _countdown.value = _countdownSeconds;
    setState(_answers.clear);
    if (_pageController.hasClients) _pageController.jumpToPage(0);
    _current = 0;
  }

  /// يُستدعى من الأب عند X/الرجوع. يرجع true إن استهلكه داخلياً (رجوع سؤال)،
  /// و false إن كنّا على أول سؤال (عندها يخرج الأب من التدفّق).
  bool handleBack() {
    _advanceTimer?.cancel();
    if (_current > 0) {
      _goTo(_current - 1);
      return true;
    }
    return false;
  }

  void _goTo(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  void _startCountdown() {
    _submitTimer?.cancel();
    _submitActive = true;
    _countdown.value = _countdownSeconds;
    _submitTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_countdown.value <= 1) {
        _countdown.value = 0;
        t.cancel();
      } else {
        _countdown.value -= 1;
      }
    });
  }

  void _onAnswer(int index, String optionId) {
    _advanceTimer?.cancel();
    setState(() => _answers[widget.questions[index].id] = optionId);
    if (_allAnswered && !_submitActive) _startCountdown();
    final isLast = index == widget.questions.length - 1;
    if (!isLast) {
      // تأخير ثانيتين ليظهر التحديد ثم الانتقال للتالي.
      _advanceTimer = Timer(const Duration(seconds: 2), () {
        if (mounted) _goTo(index + 1);
      });
    }
  }

  void _submit() {
    final answers = widget.questions
        .where((q) => _answers.containsKey(q.id))
        .map((q) => {'questionId': q.id, 'optionId': _answers[q.id]!})
        .toList();
    widget.onSubmit(answers);
  }

  @override
  void dispose() {
    _submitTimer?.cancel();
    _advanceTimer?.cancel();
    _countdown.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PageView(
      controller: _pageController,
      physics: const NeverScrollableScrollPhysics(),
      onPageChanged: (i) => setState(() => _current = i),
      children: [
        for (var i = 0; i < widget.questions.length; i++)
          ResetQuestionPage(
            question: widget.questions[i],
            selected: _answers[widget.questions[i].id],
            showPrevious: i > 0,
            onPrevious: () {
              _advanceTimer?.cancel();
              _goTo(i - 1);
            },
            showSubmit: _allAnswered,
            submitCountdown: _countdown,
            onSubmit: _submit,
            onAnswer: (optionId) => _onAnswer(i, optionId),
          ),
      ],
    );
  }
}
