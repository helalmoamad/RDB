// Quick Test for Security Features
// قم بإضافة هذا الكود في أي صفحة للاختبار السريع

import 'package:flutter/material.dart';
import 'package:rdb/services/security_service.dart';

class SecurityTestWidget extends StatelessWidget {
  const SecurityTestWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: () async {
              await SecurityService.instance.hideContent();
              ScaffoldMessenger.of(
                // ignore: use_build_context_synchronously
                context,
              ).showSnackBar(const SnackBar(content: Text('تم إخفاء المحتوى')));
            },
            child: const Text('اختبار إخفاء المحتوى'),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () async {
              await SecurityService.instance.showContent();
              ScaffoldMessenger.of(
                // ignore: use_build_context_synchronously
                context,
              ).showSnackBar(const SnackBar(content: Text('تم إظهار المحتوى')));
            },
            child: const Text('اختبار إظهار المحتوى'),
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'خطوات الاختبار:\n\n'
              '1. اضغط "اختبار إخفاء المحتوى"\n'
              '   → يجب أن تظهر شاشة سوداء\n\n'
              '2. اضغط "اختبار إظهار المحتوى"\n'
              '   → يجب أن تختفي الشاشة السوداء\n\n'
              '3. افتح Recents (زر البيت)\n'
              '   → يجب أن ترى شاشة سوداء فقط',
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
