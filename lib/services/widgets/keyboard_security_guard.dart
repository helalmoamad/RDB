import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:rdb/features/app/my_text_widget.dart';
import 'package:rdb/generated/locale_keys.g.dart';
import 'package:rdb/services/security_service.dart';

/// يفحص لوحة المفاتيح الافتراضية، وإن كانت من طرف ثالث يعرض تحذيراً أمنياً.
///
/// يُستدعى عند فتح الشاشات الحساسة (تسجيل الدخول، إدخال PIN، seed phrase،
/// التحويلات). على iOS تُمنع لوحات الطرف الثالث كلياً من AppDelegate فلا يظهر
/// شيء هنا.
///
/// مثال:
/// ```dart
/// @override
/// void initState() {
///   super.initState();
///   WidgetsBinding.instance.addPostFrameCallback((_) => guardKeyboard(context));
/// }
/// ```
Future<void> guardKeyboard(BuildContext context) async {
  final isThirdParty = await SecurityService.instance.isThirdPartyKeyboard();
  if (!isThirdParty) return;
  if (!context.mounted) return;
  await showThirdPartyKeyboardWarning(context);
}

/// يعرض حوار التحذير من لوحة مفاتيح الطرف الثالث مباشرةً (بدون فحص).
Future<void> showThirdPartyKeyboardWarning(BuildContext context) {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (_) => const _ThirdPartyKeyboardDialog(),
  );
}

class _ThirdPartyKeyboardDialog extends StatelessWidget {
  const _ThirdPartyKeyboardDialog();

  static const Color _warningRed = Color(0xFFE0413E);
  static const Color _switchYellow = Color(0xFFF0B90B);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bodyColor = theme.colorScheme.onSurface.withValues(alpha: 0.75);

    return PopScope(
      canPop: false,
      child: Dialog(
        backgroundColor:
            theme.dialogTheme.backgroundColor ?? theme.colorScheme.surface,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 28, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // أيقونة قفل مع شارة تحذير حمراء (مطابقة للتصميم)
              const _WarningLockIcon(),
              const SizedBox(height: 16),
              MyTextWidget(
                LocaleKeys.third_party_keyboard_title.tr(),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: _warningRed,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 18),
              _Bullet(
                text: LocaleKeys.third_party_keyboard_warning_1.tr(),
                color: bodyColor,
              ),
              const SizedBox(height: 12),
              _Bullet(
                text: LocaleKeys.third_party_keyboard_warning_2.tr(),
                color: bodyColor,
              ),
              const SizedBox(height: 28),
              // زر "Switch Now" — يفتح مُحدّد لوحة المفاتيح ثم يغلق الحوار
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: () async {
                    await SecurityService.instance.openKeyboardPicker();
                    if (context.mounted) Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _switchYellow,
                    foregroundColor: Colors.black,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: MyTextWidget(
                    LocaleKeys.third_party_keyboard_switch_now.tr(),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              // زر "Ignore" — يغلق الحوار فقط
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: MyTextWidget(
                  LocaleKeys.third_party_keyboard_ignore.tr(),
                  style: const TextStyle(color: _warningRed, fontSize: 15),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Bullet extends StatelessWidget {
  const _Bullet({required this.text, required this.color});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.only(top: 6, end: 8),
          child: Container(
            width: 5,
            height: 5,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
        ),
        Expanded(
          child: MyTextWidget(
            text,
            style: TextStyle(color: color, fontSize: 13, height: 1.4),
          ),
        ),
      ],
    );
  }
}

class _WarningLockIcon extends StatelessWidget {
  const _WarningLockIcon();

  @override
  Widget build(BuildContext context) {
    final iconColor = Theme.of(context).colorScheme.onSurface;
    return SizedBox(
      width: 64,
      height: 56,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          Icon(Icons.vpn_key_outlined, size: 48, color: iconColor),
          PositionedDirectional(
            top: -2,
            end: 2,
            child: Container(
              width: 20,
              height: 20,
              decoration: const BoxDecoration(
                color: Color(0xFFE0413E),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.priority_high,
                size: 14,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
