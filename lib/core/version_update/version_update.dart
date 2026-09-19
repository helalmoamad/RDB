import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:rdb/core/domin/usecases/get_starting_settings_usecase.dart';
import 'package:rdb/core/use_case/use_case.dart';
import 'package:rdb/features/app/my_text_widget.dart';
import 'package:rdb/generated/locale_keys.g.dart';
import 'package:rdb/main.dart' show applicationVersion, navigatorKey;
import 'package:url_launcher/url_launcher.dart';

enum UpdateKind { none, optional, mandatory }

/// "يتوفّر إصدار جديد": يُطلَب `startingSettings` أثناء السبلاش ويُقارَن أدنى
/// إصدار لمنصّة الجهاز مع [applicationVersion]، ثم يُعرض حوار اختياري أو إلزامي
/// فوق كل شيء عبر الـ root navigator.
class VersionUpdate {
  VersionUpdate._();

  static const String androidPackageId = 'com.rdb.www';

  /// Numeric App Store id ("id1234567890" -> "1234567890"). Empty = unknown,
  /// so [_appStoreUri] looks the app up by [iosBundleId].
  static const String appStoreId = '';

  /// iOS bundle id, used only when [appStoreId] is empty.
  static const String iosBundleId = 'com.rdb.www';

  static const Color _blue = Color(0xFF007AFF);
  static const Color _titleColor = Color(0xFF1D1D1F);
  static const Color _grey = Color(0xFF6E6E73);

  static bool _dialogShown = false;

  static String get _playStoreWebUrl =>
      'https://play.google.com/store/apps/details?id=$androidPackageId';

  // ---------------------------------------------------------------- decision

  /// Pure. Only the hundreds digit decides if the user may skip:
  /// 150 -> 151..199 optional, 150 -> 200+ mandatory, null -> none.
  static UpdateKind decide({required int current, required int? minVersion}) {
    if (minVersion == null || current >= minVersion) return UpdateKind.none;
    return minVersion ~/ 100 > current ~/ 100
        ? UpdateKind.mandatory
        : UpdateKind.optional;
  }

  /// Pure. Reads this platform's minimum from the `startingSettings` body.
  static int? readMinVersion(Object? body, {required bool isIOS}) {
    if (body is! Map) return null;
    if (body['isSuccessful'] == false) return null;
    final data = body['data'];
    if (data is! Map) return null;
    final setting = data['starting-setting'];
    if (setting is! Map) return null;
    final raw = setting[isIOS ? 'ios_min_version' : 'android_min_version'];
    if (raw is int) return raw;
    if (raw is num) return raw.toInt();
    if (raw is String) return int.tryParse(raw.trim());
    return null;
  }

  // ----------------------------------------------------------------- network

  /// Never throws. Any failure means "no update". Not cached: only a fresh
  /// response decides.
  static Future<UpdateKind> _fetchUpdateKind() async {
    try {
      final result = await GetIt.I<GetStartingSettingsUseCase>()(NoParams());
      Object? body = result.fold((_) => null, (body) => body);
      if (body is String) body = jsonDecode(body);
      final int? min = readMinVersion(body, isIOS: Platform.isIOS);
      return decide(current: applicationVersion, minVersion: min);
    } catch (_) {
      return UpdateKind.none;
    }
  }

  // ------------------------------------------------------------------ splash

  /// Call once when splash starts, together with splash's other work. Leave
  /// splash only after this completes.
  ///  - none / failed:   completes right away.
  ///  - optional:        completes when the user closes the dialog.
  ///  - mandatory:       never completes, so the app stays behind the dialog.
  ///  - no answer after [waitAtMost]: completes; a late answer still shows the
  ///    dialog over whatever screen is open by then.
  static Future<void> checkOnSplash({
    Duration waitAtMost = const Duration(seconds: 6),
  }) async {
    final Future<UpdateKind> request = _fetchUpdateKind();
    final UpdateKind kind;
    try {
      kind = await request.timeout(waitAtMost);
    } on TimeoutException {
      unawaited(
        request.then((late) {
          if (late != UpdateKind.none) showUpdateDialog(late);
        }),
      );
      return;
    }
    if (kind == UpdateKind.none) return;
    await showUpdateDialog(kind);
  }

  // ------------------------------------------------------------------ dialog

  static Future<void> showUpdateDialog(UpdateKind kind) async {
    if (kind == UpdateKind.none || _dialogShown) return;
    // Wait for a frame so the root navigator is surely mounted.
    if (navigatorKey.currentContext == null) {
      await WidgetsBinding.instance.endOfFrame;
    }
    final BuildContext? rootContext = navigatorKey.currentContext;
    if (rootContext == null || !rootContext.mounted) return;
    _dialogShown = true;

    final bool isMandatory = kind == UpdateKind.mandatory;
    await showDialog<void>(
      context: rootContext,
      useRootNavigator: true,
      barrierDismissible: false,
      builder: (dialogContext) {
        final String title = LocaleKeys.new_update_available.tr();
        final String message = isMandatory
            ? LocaleKeys.current_version_no_longer_works_message.tr()
            : LocaleKeys.newer_version_available_message.tr();
        final String updateLabel = LocaleKeys.update_now.tr();
        final String notNowLabel = LocaleKeys.not_now.tr();

        void onUpdate() {
          // Mandatory: keep the dialog open behind the store page.
          if (!isMandatory) Navigator.of(dialogContext).pop();
          openStore();
        }

        void onNotNow() => Navigator.of(dialogContext).pop();

        return PopScope(
          canPop: !isMandatory,
          child: Platform.isIOS
              ? CupertinoAlertDialog(
                  title: Column(
                    children: [
                      const Icon(
                        Icons.system_update_rounded,
                        size: 40,
                        color: _blue,
                      ),
                      const SizedBox(height: 12),
                      MyTextWidget(
                        title,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: _titleColor,
                        ),
                      ),
                    ],
                  ),
                  content: Column(
                    children: [
                      MyTextWidget(
                        message,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 13,
                          color: _grey,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                  actions: [
                    Row(
                      children: [
                        if (!isMandatory)
                          Expanded(
                            child: CupertinoButton(
                              onPressed: onNotNow,
                              child: Text(
                                notNowLabel,
                                style: const TextStyle(
                                  color: _grey,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                        Expanded(
                          child: CupertinoButton.filled(
                            onPressed: onUpdate,
                            child: Text(
                              updateLabel,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                )
              : AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  title: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _blue.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.system_update_rounded,
                          size: 40,
                          color: _blue,
                        ),
                      ),
                      const SizedBox(height: 12),
                      MyTextWidget(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
                          color: _titleColor,
                        ),
                      ),
                    ],
                  ),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      MyTextWidget(
                        message,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: _grey,
                          height: 1.4,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                    ],
                  ),
                  actions: [
                    Row(
                      children: [
                        if (!isMandatory) ...[
                          Expanded(
                            child: TextButton(
                              onPressed: onNotNow,
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Text(
                                notNowLabel,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: _grey,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                        ],
                        Expanded(
                          child: ElevatedButton(
                            onPressed: onUpdate,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              backgroundColor: _blue,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              elevation: 2,
                            ),
                            child: Text(
                              updateLabel,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
        );
      },
    );
  }

  // ------------------------------------------------------------------- store

  /// Google Play on Android, App Store on iOS. Tries the store app first,
  /// then the web page. Never throws.
  static Future<void> openStore() async {
    final List<Uri> candidates = Platform.isIOS
        ? [await _appStoreUri()]
        : [
            Uri.parse('market://details?id=$androidPackageId'),
            Uri.parse(_playStoreWebUrl),
          ];
    for (final uri in candidates) {
      try {
        if (await launchUrl(uri, mode: LaunchMode.externalApplication)) return;
      } catch (_) {}
    }
    try {
      await launchUrl(candidates.last, mode: LaunchMode.platformDefault);
    } catch (_) {}
  }

  static Future<Uri> _appStoreUri() async {
    if (appStoreId.isNotEmpty) {
      return Uri.parse('https://apps.apple.com/app/id$appStoreId');
    }
    // No id in the code: ask Apple by bundle id (public, no key needed). The
    // absolute URI bypasses any base URL, and no auth header is added here.
    try {
      final response = await GetIt.I<Dio>()
          .getUri<Object?>(
            Uri.https('itunes.apple.com', '/lookup', {'bundleId': iosBundleId}),
          )
          .timeout(const Duration(seconds: 6));
      Object? body = response.data;
      // Apple answers with text/javascript, so Dio leaves it as a String.
      if (body is String) body = jsonDecode(body);
      final results = body is Map ? body['results'] : null;
      if (results is List && results.isNotEmpty) {
        final first = results.first;
        final url = first is Map ? first['trackViewUrl'] : null;
        if (url is String && url.isNotEmpty) return Uri.parse(url);
      }
    } catch (_) {}
    // Not on the App Store yet: fall back to the Play Store web page.
    return Uri.parse(_playStoreWebUrl);
  }
}
