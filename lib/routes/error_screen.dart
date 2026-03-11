import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/app/my_text_widget.dart';

class ErrorScreen extends StatelessWidget {
  const ErrorScreen({this.exception, super.key});
  final GoException? exception;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: MyTextWidget(exception?.message ?? 'No Error Message'),
      ),
    );
  }
}
