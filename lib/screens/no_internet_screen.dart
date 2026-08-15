import 'package:easy_localization/easy_localization.dart' as tran;
import 'package:flutter/material.dart';
import 'package:rdb/generated/locale_keys.g.dart';

/// Full-screen overlay shown when internet connectivity is lost.
/// Cannot be dismissed — disappears automatically when connectivity returns.
class NoInternetScreen extends StatefulWidget {
  const NoInternetScreen({super.key, required this.languageCode});

  final String languageCode;

  @override
  State<NoInternetScreen> createState() => _NoInternetScreenState();
}

class _NoInternetScreenState extends State<NoInternetScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.92, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  bool get _isRtl => widget.languageCode == 'ar' || widget.languageCode == 'ku';

  // النصوص تأتي من نظام ترجمة التطبيق (easy_localization) بدل تثبيتها في الكود،
  // فتتبع لغة التطبيق المختارة تلقائياً.
  String _title() => LocaleKeys.no_internet_title.tr();

  String _subtitle() => LocaleKeys.no_internet_subtitle.tr();

  String _reconnecting() => LocaleKeys.no_internet_waiting_reconnect.tr();

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: _isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: Material(
        color: Colors.white,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Spacer(flex: 2),
                ScaleTransition(
                  scale: _pulseAnimation,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF4F5F5),
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.wifi_off_rounded,
                        size: 52,
                        color: Color(0xff2C2A2A),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  _title(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xff2C2A2A),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  _subtitle(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.normal,
                    color: Color(0xff585858),
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 40),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Color(0xff0080FF),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _reconnecting(),
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xff0080FF),
                      ),
                    ),
                  ],
                ),
                const Spacer(flex: 3),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
