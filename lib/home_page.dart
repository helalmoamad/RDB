import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_it/get_it.dart';
import 'package:rdb/core/domin/repositories/prefs_repository.dart';

import 'package:rdb/core/utils/responsive_padding.dart';
import 'package:trydos_wallet/trydos_wallet.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // 🛡️ حماية حالة الصفحة الرئيسية

  @override
  void initState() {
    // تهيئة المحفظة
    TrydosWallet.init(
      TrydosWalletConfig(
        baseUrl: dotenv.env['WALLET_URL'] ?? '', // رابط الـ API
        token: GetIt.I<PrefsRepository>().walletToken, // استخدم القيمة الفعلية
        languageCode: "en",
        //LanguageService.languageCode,
        // استخدم اللغة الحالية
        allowBadCertificate: true, // true للتطوير فقط عند خطأ SSL
      ),
    );
    super.initState();
  }

  /// جلب البيانات عند السحب للتحديث (خارج build لتحسين الأداء)

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: HWEdgeInsets.symmetric(horizontal: 0.w),
        child: TrydosWalletWelcomeScreen(),
      ),
    );
  }
}
