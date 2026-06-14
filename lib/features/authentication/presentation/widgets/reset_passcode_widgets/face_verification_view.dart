import 'dart:convert';

import 'package:camera/camera.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:rdb/features/authentication/presentation/manager/auth_bloc.dart';
import 'package:rdb/generated/locale_keys.g.dart';

/// شاشة التحقّق بالوجه (step-up) في تدفّق إعادة تعيين رمز المرور.
/// تعرض عنواناً + نصّاً توضيحياً + معاينة كاميرا أمامية داخل صندوق دائري، ثم زرّ
/// التقاط. عند الالتقاط نرسل إطاراً واحداً (data URL) عبر [ReverifyFaceEvent].
/// النجاح يعالجه [ForgetPasscodeFlow] (ينتقل لتعيين الرمز الجديد دون رجوع).
class FaceVerificationView extends StatefulWidget {
  const FaceVerificationView({required this.challengeId, super.key});

  final String challengeId;

  @override
  State<FaceVerificationView> createState() => _FaceVerificationViewState();
}

class _FaceVerificationViewState extends State<FaceVerificationView>
    with WidgetsBindingObserver {
  CameraController? _controller;
  bool _initializing = true;
  bool _permissionDenied = false;
  bool _capturing = false;

  static const Color _dark = Color(0xff1D1D1D);
  static const Color _muted = Color(0xff5D5C5D);
  static const Color _blue = Color(0xff2E4C8E);

  /// انعكاس المعاينة أفقياً (سلوك المرآة للسيلفي). إن ظهرت بالاتجاه الخاطئ على
  /// جهازك، بدّل هذه القيمة فقط (بصري بحت — لا يؤثّر على الصورة المُرسَلة للتحقّق).
  static const bool _mirrorPreview = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _setupCamera();
    // بدء جلسة التحقّق بالوجه فور دخول الشاشة (قبل الالتقاط).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _start();
    });
  }

  void _start() {
    context.read<AuthBloc>().add(
      ReverifyStartEvent(challengeId: widget.challengeId),
    );
  }

  Future<void> _setupCamera() async {
    if (mounted) {
      setState(() {
        _initializing = true;
        _permissionDenied = false;
      });
    }
    try {
      final status = await Permission.camera.request();
      if (!status.isGranted) {
        if (mounted) {
          setState(() {
            _initializing = false;
            _permissionDenied = true;
          });
        }
        return;
      }
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        if (mounted) setState(() => _initializing = false);
        return;
      }
      final front = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );
      final controller = CameraController(
        front,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );
      await controller.initialize();
      if (!mounted) {
        await controller.dispose();
        return;
      }
      setState(() {
        _controller = controller;
        _initializing = false;
      });
    } catch (_) {
      if (mounted) setState(() => _initializing = false);
    }
  }

  Future<void> _capture() async {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized || _capturing) {
      return;
    }
    setState(() => _capturing = true);
    try {
      final file = await controller.takePicture();
      final bytes = await file.readAsBytes();
      final dataUrl = 'data:image/jpeg;base64,${base64Encode(bytes)}';
      if (!mounted) return;
      context.read<AuthBloc>().add(
        ReverifyFaceEvent(
          challengeId: widget.challengeId,
          liveFaceImageData: dataUrl,
        ),
      );
    } catch (_) {
      // يبقى الزرّ متاحاً لإعادة المحاولة.
    } finally {
      if (mounted) setState(() => _capturing = false);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final controller = _controller;
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      _controller = null;
      controller?.dispose();
    } else if (state == AppLifecycleState.resumed && controller == null) {
      _setupCamera();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      buildWhen: (p, c) =>
          p.reverifyFaceStatus != c.reverifyFaceStatus ||
          p.reverifyStartStatus != c.reverifyStartStatus,
      builder: (context, s) {
        final starting = s.reverifyStartStatus == ReverifyStartStatus.loading;
        final startFailed =
            s.reverifyStartStatus == ReverifyStartStatus.failure;
        final started = s.reverifyStartStatus == ReverifyStartStatus.success;
        final verifying = s.reverifyFaceStatus == ReverifyFaceStatus.loading;
        final verifyFailed =
            s.reverifyFaceStatus == ReverifyFaceStatus.failed ||
            s.reverifyFaceStatus == ReverifyFaceStatus.error;
        return SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 30.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                LocaleKeys.face_verify_title.tr(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _dark,
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10.h),
              Text(
                LocaleKeys.face_verify_subtitle.tr(),
                textAlign: TextAlign.center,
                style: TextStyle(color: _muted, fontSize: 13.sp, height: 1.4),
              ),
              SizedBox(height: 50.h),
              _cameraBox(verifying),
              SizedBox(height: 30.h),
              if (startFailed || verifyFailed) ...[
                Text(
                  s.resetError?.isNotEmpty == true
                      ? s.resetError!
                      : LocaleKeys.face_verify_failed.tr(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: const Color(0xffFF5F61),
                    fontSize: 12.sp,
                  ),
                ),
                SizedBox(height: 30.h),
              ],
              _actionButton(
                started: started,
                starting: starting,
                startFailed: startFailed,
                verifying: verifying,
                verifyFailed: verifyFailed,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _cameraBox(bool verifying) {
    final double size = 280.w;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xffF2F4F8),
        shape: BoxShape.circle,
        border: Border.all(color: _blue.withValues(alpha: 0.35), width: 3),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          _preview(),
          if (verifying)
            Container(
              color: Colors.black.withValues(alpha: 0.35),
              alignment: Alignment.center,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(color: Colors.white),
                  SizedBox(height: 12.h),
                  Text(
                    LocaleKeys.face_verify_checking.tr(),
                    style: TextStyle(color: Colors.white, fontSize: 13.sp),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _preview() {
    if (_initializing) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_permissionDenied) {
      return Padding(
        padding: EdgeInsets.all(20.w),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.no_photography_outlined, color: _muted, size: 36.sp),
              SizedBox(height: 10.h),
              Text(
                LocaleKeys.face_verify_camera_permission.tr(),
                textAlign: TextAlign.center,
                style: TextStyle(color: _muted, fontSize: 12.sp),
              ),
              SizedBox(height: 8.h),
              TextButton(
                onPressed: openAppSettings,
                child: Text(LocaleKeys.face_verify_open_settings.tr()),
              ),
            ],
          ),
        ),
      );
    }
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) {
      return const Center(child: Icon(Icons.camera_alt_outlined));
    }
    // معاينة الكاميرا تملأ الدائرة. الانعكاس الأفقي (مرآة) اختياري عبر
    // _mirrorPreview — بصري بحت لا يؤثّر على الصورة المُرسَلة للتحقّق.
    Widget preview = ClipOval(
      child: FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(
          width: controller.value.previewSize?.height ?? 280.w,
          height: controller.value.previewSize?.width ?? 280.w,
          child: CameraPreview(controller),
        ),
      ),
    );
    if (_mirrorPreview) {
      preview = Transform.flip(flipX: true, child: preview);
    }
    return preview;
  }

  Widget _actionButton({
    required bool started,
    required bool starting,
    required bool startFailed,
    required bool verifying,
    required bool verifyFailed,
  }) {
    final bool cameraReady = _controller?.value.isInitialized == true;
    final bool busy = starting || verifying || _capturing;
    // عند فشل البدء: الزرّ يعيد محاولة start. غير ذلك: يلتقط عند جهوز الكاميرا
    // ونجاح البدء.
    final bool enabled = startFailed || (cameraReady && started && !busy);
    final String label = verifying
        ? LocaleKeys.face_verify_checking.tr()
        : starting
        ? LocaleKeys.face_verify_preparing.tr()
        : (startFailed || verifyFailed)
        ? LocaleKeys.face_verify_retry.tr()
        : LocaleKeys.face_verify_capture.tr();
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: enabled ? (startFailed ? _start : _capture) : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: _blue,
          disabledBackgroundColor: const Color(0xffEDEDED),
          foregroundColor: Colors.white,
          minimumSize: Size(double.infinity, 56.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18.r),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
