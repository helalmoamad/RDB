import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get_it/get_it.dart';
import 'package:rdb/common/constant/design/assets_provider.dart';
import 'package:rdb/core/domin/repositories/prefs_repository.dart';
import 'package:rdb/core/utils/extensions/build_context.dart';
import 'package:rdb/features/authentication/presentation/manager/auth_bloc.dart';
import 'package:rdb/theme/typography.dart';
import 'package:rdb/generated/locale_keys.g.dart';

class SwitchWepAppPage extends StatefulWidget {
  final VoidCallback onSuccess;
  const SwitchWepAppPage({required this.onSuccess, super.key});

  @override
  State<SwitchWepAppPage> createState() => _SwitchWepAppPageState();
}

class _SwitchWepAppPageState extends State<SwitchWepAppPage> {
  final PrefsRepository prefsRepository = GetIt.I<PrefsRepository>();
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    // إعادة تعيين الحالة عند ظهور الطبقة حتى لا تبقى حالة نجاح قديمة
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<AuthBloc>().add(const ResetSwitchToAppEvent());
      }
    });
    // تحديث دوري لعدّاد الدقائق أثناء عرض الشاشة
    _ticker = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  /// الدقائق المنقضية منذ وصول حدث إظهار switch (تستمر عبر الخلفية والعودة).
  int get _elapsedMinutes {
    final shownAt = prefsRepository.switchShownAtMs;
    if (shownAt == null) return 0;
    final diffMs = DateTime.now().millisecondsSinceEpoch - shownAt;
    return diffMs <= 0 ? 0 : diffMs ~/ 60000;
  }

  @override
  Widget build(BuildContext context) {
    String title = GetIt.I<PrefsRepository>().userName ?? "";
    final int minutes = _elapsedMinutes + 1;

    // واجهة شفافة مع الحقول ثابتة عند فتح لوحة المفاتيح
    return PopScope(
      canPop: false,
      child: GestureDetector(
        onHorizontalDragStart: (_) {},
        child: Align(
          alignment: Alignment.center,
          child: BlocConsumer<AuthBloc, AuthState>(
            listenWhen: (previous, current) =>
                previous.switchToAppStatus != current.switchToAppStatus,
            listener: (context, state) async {
              if (state.switchToAppStatus == SwitchToAppStatus.success) {
                // بعد النجاح بـ 3 ثوانٍ ننتقل لصفحة السبلاش لإعادة تهيئة التطبيق
                // وتحميل الصفحة الرئيسية من جديد
                await Future.delayed(const Duration(seconds: 3));
                widget.onSuccess();
              }
            },
            buildWhen: (previous, current) =>
                previous.switchToAppStatus != current.switchToAppStatus,
            builder: (context, state) {
              final status = state.switchToAppStatus;
              final bool loading = status == SwitchToAppStatus.loading;
              final bool success = status == SwitchToAppStatus.success;
              final bool initial = !loading && !success;
              return SizedBox(
                height: 1.sh,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.h),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: 420.w),
                    child: Material(
                      color: Colors.transparent,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Spacer(),
                          SvgPicture.asset(
                            AppAssets.verifiedSvg,
                            width: 23,
                            height: 23,
                            // ignore: deprecated_member_use
                            color: Color(
                              (prefsRepository.isKycVerification ?? false)
                                  ? 0xff388CFF
                                  : 0xff8D8D8D,
                            ),
                          ),
                          SizedBox(height: 10.h),
                          Text(
                            title,
                            style: context.textTheme.titleLarge?.rq.copyWith(
                              color: const Color(0xff1D1D1D),
                              height: 1.42,
                              fontSize: 18.sp,
                            ),
                          ),
                          SizedBox(height: 25.h),
                          loading || success
                              ? Text(
                                  LocaleKeys.web_session_lasted_and_ended.tr(
                                    namedArgs: {'minutes': '$minutes'},
                                  ),
                                  style: context.textTheme.titleLarge?.rq
                                      .copyWith(
                                        color: const Color(0xff1D1D1D),
                                        height: 1.42,
                                        fontSize: 12.sp,
                                      ),
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      LocaleKeys.you_have_logged_in_via_web
                                          .tr(),
                                      style: context.textTheme.titleLarge?.rq
                                          .copyWith(
                                            color: const Color(0xff388CFF),
                                            height: 1.42,
                                            fontSize: 12.sp,
                                          ),
                                    ),
                                    Text(
                                      " $minutes ${LocaleKeys.minute.tr()} ",
                                      style: context.textTheme.titleLarge?.bq
                                          .copyWith(
                                            color: const Color(0xff388CFF),
                                            height: 1.42,
                                            fontSize: 12.sp,
                                          ),
                                    ),
                                    Text(
                                      LocaleKeys.ago.tr(),
                                      style: context.textTheme.titleLarge?.rq
                                          .copyWith(
                                            color: const Color(0xff388CFF),
                                            height: 1.42,
                                            fontSize: 12.sp,
                                          ),
                                    ),
                                  ],
                                ),

                          SizedBox(height: 20.h),

                          success
                              ? SizedBox.shrink()
                              : GestureDetector(
                                  onTap: initial
                                      ? () => context.read<AuthBloc>().add(
                                          const SwitchToAppEvent(),
                                        )
                                      : null,
                                  child: SvgPicture.asset(
                                    loading
                                        ? AppAssets.switche
                                        : AppAssets.switchOff,
                                    width: 50,
                                    height: 50,
                                  ),
                                ),
                          SizedBox(height: 10.h),
                          success
                              ? SizedBox.shrink()
                              : Text(
                                  loading
                                      ? LocaleKeys.switching_clearing_web_files
                                            .tr()
                                      : LocaleKeys.switch_to_here.tr(),
                                  style: context.textTheme.titleLarge?.rq
                                      .copyWith(
                                        color: const Color(0xff1D1D1D),
                                        height: 1.42,
                                        fontSize: 12.sp,
                                      ),
                                ),

                          if (loading) ...[Spacer(), SizedBox(height: 80.h)],
                          if (initial) ...[
                            Spacer(),
                            SvgPicture.asset(
                              AppAssets.privacySvg,
                              colorFilter: const ColorFilter.mode(
                                Color(0xff388CFF),
                                BlendMode.srcIn,
                              ),
                              width: 15,
                              height: 15,
                            ),
                            SizedBox(height: 10.h),
                            Text(
                              LocaleKeys.your_privacy_safe.tr(),
                              style: context.textTheme.titleLarge?.rq.copyWith(
                                color: const Color(0xff388CFF),
                                height: 1.42,
                                fontSize: 12.sp,
                              ),
                            ),
                            SizedBox(height: 35.h),
                          ],
                          if (success) ...[
                            SvgPicture.asset(
                              AppAssets.privacySvg,
                              colorFilter: const ColorFilter.mode(
                                Color(0xff388CFF),
                                BlendMode.srcIn,
                              ),
                              width: 15,
                              height: 15,
                            ),
                            SizedBox(height: 10.h),
                            Text(
                              LocaleKeys.your_privacy_safe.tr(),
                              style: context.textTheme.titleLarge?.rq.copyWith(
                                color: const Color(0xff388CFF),
                                height: 1.42,
                                fontSize: 12.sp,
                              ),
                            ),
                            SizedBox(height: 10.h),
                            Text(
                              LocaleKeys.web_session_closed_files_deleted.tr(),
                              style: context.textTheme.titleLarge?.rq.copyWith(
                                color: const Color(0xff388CFF),
                                height: 1.42,
                                fontSize: 12.sp,
                              ),
                            ),
                            Spacer(),
                            SizedBox(height: 78.h),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
