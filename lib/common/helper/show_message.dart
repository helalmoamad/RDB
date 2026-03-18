import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../main.dart';

OverlayEntry? _activeNotificationEntry;

bool _isRTL(BuildContext context) {
  return Directionality.of(context) == TextDirection.rtl;
}

showMessage(
  String message, {
  bool hasError = false,
  bool showInRelease = false,
  Color? backGroundColor,
  Color? foreGroundColor,
  Toast timeShowing = Toast.LENGTH_LONG,
  BuildContext? context,
}) {
  if (kDebugMode || showInRelease || hasError) {
    final currentContext = context ?? navigatorKey.currentState?.context;

    if (currentContext != null) {
      try {
        if (hasError) {
          showErrorMessage(currentContext, message);
        } else {
          showSuccessMessage(currentContext, message);
        }
      } catch (_) {
        Fluttertoast.cancel().then(
          (value) => Fluttertoast.showToast(
            msg: message,
            backgroundColor: hasError ? Colors.red : Colors.green,
            textColor: Colors.white,
            fontSize: 16,
            toastLength: timeShowing,
            gravity: ToastGravity.TOP,
          ),
        );
      }
    } else {
      Fluttertoast.cancel().then(
        (value) => Fluttertoast.showToast(
          msg: message,
          backgroundColor: hasError ? Colors.red : Colors.green,
          textColor: Colors.white,
          fontSize: 16,
          toastLength: timeShowing,
          gravity: ToastGravity.TOP,
        ),
      );
    }
  }
}

showSuccessMessage(
  BuildContext context,
  String message, {
  String? actionText,
  VoidCallback? onActionPressed,
}) {
  _showTopNotification(context, message);
}

showErrorMessage(
  BuildContext context,
  String message, {
  String? actionText,
  VoidCallback? onActionPressed,
}) {
  _showTopNotification(context, message);
}

showWarningMessage(
  BuildContext context,
  String message, {
  String? actionText,
  VoidCallback? onActionPressed,
}) {
  _showTopNotification(context, message);
}

void _showTopNotification(
  BuildContext context,
  String message, {
  Duration duration = const Duration(seconds: 3),
}) {
  final overlayState =
      Overlay.maybeOf(context, rootOverlay: true) ??
      navigatorKey.currentState?.overlay;

  if (overlayState == null) {
    Fluttertoast.cancel().then(
      (value) => Fluttertoast.showToast(
        msg: message,
        backgroundColor: const Color(0xff444146),
        textColor: Colors.white,
        fontSize: 16,
        toastLength: duration.inSeconds > 2
            ? Toast.LENGTH_LONG
            : Toast.LENGTH_SHORT,
        gravity: ToastGravity.TOP,
      ),
    );
    return;
  }

  _removeActiveNotification();

  late final OverlayEntry overlayEntry;
  overlayEntry = OverlayEntry(
    builder: (overlayContext) => Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          _TopNotificationWidget(
            message: message,
            duration: duration,
            onDismissed: () {
              if (_activeNotificationEntry == overlayEntry) {
                _removeActiveNotification();
              }
            },
          ),
        ],
      ),
    ),
  );

  _activeNotificationEntry = overlayEntry;
  overlayState.insert(overlayEntry);
}

void _removeActiveNotification() {
  final entry = _activeNotificationEntry;
  if (entry == null) return;

  _activeNotificationEntry = null;
  try {
    entry.remove();
  } catch (_) {
    // Ignore removal if the overlay was already removed.
  }
}

class _TopNotificationWidget extends StatefulWidget {
  const _TopNotificationWidget({
    required this.message,
    required this.duration,
    required this.onDismissed,
  });

  final String message;
  final Duration duration;
  final VoidCallback onDismissed;

  @override
  State<_TopNotificationWidget> createState() => _TopNotificationWidgetState();
}

class _TopNotificationWidgetState extends State<_TopNotificationWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _offsetAnimation;
  bool _isDismissing = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: const Offset(0, 0),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _controller.forward();

    Future.delayed(widget.duration, () async {
      if (mounted) {
        await _dismiss();
      }
    });
  }

  Future<void> _dismiss() async {
    if (_isDismissing) return;
    _isDismissing = true;

    if (_controller.status != AnimationStatus.dismissed) {
      await _controller.reverse();
    }

    if (mounted) {
      widget.onDismissed();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top + 16;

    return Positioned(
      top: topPadding,
      left: 16,
      right: 16,
      child: SlideTransition(
        position: _offsetAnimation,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xff444146),
              borderRadius: BorderRadius.circular(14),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x3D000000),
                  blurRadius: 14,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: const BoxDecoration(
                    color: Color(0xffFF4D4F),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.priority_high_rounded,
                      color: Colors.white,
                      size: 15,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    widget.message,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Quicksand',
                      height: 1.1,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textDirection: _isRTL(context)
                        ? TextDirection.rtl
                        : TextDirection.ltr,
                  ),
                ),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  icon: const Icon(
                    Icons.close,
                    color: Color(0xff9A999D),
                    size: 22,
                  ),
                  onPressed: _dismiss,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
