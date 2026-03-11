import 'package:flutter/material.dart';

abstract class ThemeState<T extends StatefulWidget> extends State<T> {
  ThemeData get theme => Theme.of(context);
  TextTheme get textTheme => Theme.of(context).textTheme;
  ColorScheme get colorScheme => Theme.of(context).colorScheme;
}

// ignore: must_be_immutable
abstract class ThemeStateless extends StatelessWidget {
  ThemeStateless({super.key, required this.child, this.onBuild});

  ColorScheme? colorScheme;
  ThemeData? theme;
  TextTheme? textTheme;

  final Widget child;
  final VoidCallback? onBuild;

  @override
  Widget build(BuildContext context) {
    colorScheme = Theme.of(context).colorScheme;
    theme = Theme.of(context);
    textTheme = Theme.of(context).textTheme;
    onBuild?.call();
    return child;
  }
}
