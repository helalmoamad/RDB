import 'package:flutter/material.dart';
import 'package:rdb/screens/no_internet_screen.dart';
import 'package:rdb/service/connectivity_service.dart';

/// Wraps the whole app and overlays [NoInternetScreen] whenever the device
/// has no real internet access.
class ConnectivityGate extends StatefulWidget {
  const ConnectivityGate({
    super.key,
    required this.child,
    required this.languageCode,
    this.onReconnected,
  });

  final Widget child;
  final String languageCode;

  /// Called once each time connectivity is restored — refresh data here.
  final VoidCallback? onReconnected;

  @override
  State<ConnectivityGate> createState() => _ConnectivityGateState();
}

class _ConnectivityGateState extends State<ConnectivityGate> {
  bool _isOffline = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ConnectivityService.instance.initialize().then((_) {
        if (!mounted) return;
        setState(() {
          _isOffline = !ConnectivityService.instance.isOnline.value;
        });
      });
      ConnectivityService.instance.isOnline.addListener(_onConnectivityChanged);
    });
  }

  @override
  void dispose() {
    ConnectivityService.instance.isOnline
        .removeListener(_onConnectivityChanged);
    super.dispose();
  }

  void _onConnectivityChanged() {
    final online = ConnectivityService.instance.isOnline.value;
    if (!mounted) return;
    setState(() => _isOffline = !online);
    if (online) widget.onReconnected?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (_isOffline)
          Positioned.fill(
            child: NoInternetScreen(languageCode: widget.languageCode),
          ),
      ],
    );
  }
}
