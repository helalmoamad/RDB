import 'package:dotted_border/dotted_border.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:rdb/common/constant/design/assets_provider.dart';
import 'package:rdb/common/helper/show_message.dart';
import 'package:rdb/core/domin/repositories/prefs_repository.dart';
import 'package:rdb/core/utils/extensions/build_context.dart';
import 'package:rdb/core/utils/last_pages_tracker.dart';
import 'package:rdb/features/app/rdb_loading.dart';
import 'package:rdb/features/authentication/presentation/manager/auth_bloc.dart';
import 'package:rdb/generated/locale_keys.g.dart';
import 'package:rdb/routes/router.dart';
import 'package:rdb/service/language_service.dart';
import 'package:rdb/theme/typography.dart';

class EnterNamePage extends StatefulWidget {
  const EnterNamePage({super.key});

  @override
  State<EnterNamePage> createState() => _EnterNamePageState();
}

class _EnterNamePageState extends State<EnterNamePage> {
  final PrefsRepository _prefsRepository = GetIt.I<PrefsRepository>();
  final TextEditingController _nameController = TextEditingController();

  late final AuthBloc _authBloc;

  int get _nameLength => _nameController.text.replaceAll(' ', '').length;

  bool get _canContinue => _nameLength >= 6;

  bool get _showValidation => _nameLength > 0 && _nameLength < 6;

  @override
  void initState() {
    super.initState();
    _authBloc = context.read<AuthBloc>();
    LastPagesTracker.push('EnterNamePage');
    _nameController.addListener(_handleNameChanged);
  }

  @override
  void dispose() {
    _nameController.removeListener(_handleNameChanged);
    _nameController.dispose();
    super.dispose();
  }

  void _handleNameChanged() {
    setState(() {});
  }

  Future<void> _continue() async {
    if (!_canContinue ||
        _authBloc.state.updateUserProfileStatus ==
            UpdateUserProfileStatus.loading) {
      return;
    }

    final normalizedName = _nameController.text
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .join(' ');

    _authBloc.add(UpdateUserProfileEvent(fullName: normalizedName));
  }

  @override
  Widget build(BuildContext context) {
    FlutterError.onError = (FlutterErrorDetails error) {
      LastPagesTracker.sendErrorToBlocAndLog(error);
      FlutterError.dumpErrorToConsole(error);
    };

    return BlocConsumer<AuthBloc, AuthState>(
      listenWhen: (previous, current) =>
          previous.updateUserProfileStatus != current.updateUserProfileStatus,
      listener: (context, state) {
        if (state.updateUserProfileStatus == UpdateUserProfileStatus.success) {
          final passcode = _prefsRepository.passcode;
          if (passcode == null || passcode.isEmpty) {
            context.go(GRouter.config.applicationRoutes.kPinCodeSetupPage);
          } else {
            context.go(GRouter.config.applicationRoutes.kBasePage);
          }
        } else if (state.updateUserProfileStatus ==
            UpdateUserProfileStatus.failure) {
          showMessage(
            (state.updateUserProfileError ?? '').isEmpty
                ? 'Failed to update profile'
                : state.updateUserProfileError!,
            hasError: true,
            context: context,
          );
        }
      },
      buildWhen: (previous, current) =>
          previous.updateUserProfileStatus != current.updateUserProfileStatus,
      builder: (context, state) {
        return Scaffold(
          backgroundColor: const Color(0xffF4FFF4),
          body: SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 255.h),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: Text(
                      '${LocaleKeys.enter_your_name.tr()} !',
                      style: context.textTheme.headlineSmall?.bq.copyWith(
                        color: const Color(0xff1D1D1D),
                        fontSize: 30.sp,
                        height: 1.25,
                      ),
                    ),
                  ),
                  10.verticalSpace,
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: Text(
                      LocaleKeys.last_step.tr(),
                      style: context.textTheme.bodySmall?.mq.copyWith(
                        color: const Color(0xff1D1D1D),
                        fontSize: 16.sp,
                        height: 1.25,
                      ),
                    ),
                  ),
                  10.verticalSpace,
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: Text(
                      LocaleKeys.ensure_greater_security_and_protect_your_funds
                          .tr(),
                      style: context.textTheme.displayMedium?.rq.copyWith(
                        color: const Color(0xff1D1D1D),
                        fontSize: 12.sp,
                        height: 1.25,
                      ),
                    ),
                  ),
                  SizedBox(height: 115.h),
                  SizedBox(
                    child: _NameInputField(
                      controller: _nameController,
                      canContinue: _canContinue,
                      showValidation: _showValidation,
                      isLoading:
                          state.updateUserProfileStatus ==
                          UpdateUserProfileStatus.loading,
                      onContinue: _continue,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _NameInputField extends StatelessWidget {
  const _NameInputField({
    required this.controller,
    required this.canContinue,
    required this.showValidation,
    required this.isLoading,
    required this.onContinue,
  });

  final TextEditingController controller;
  final bool canContinue;
  final bool showValidation;
  final bool isLoading;
  final Future<void> Function() onContinue;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 60.h,
          child: DottedBorder(
            padding: EdgeInsets.zero,
            borderType: BorderType.RRect,
            borderPadding: EdgeInsets.all(0),
            strokeCap: StrokeCap.round,
            strokeWidth: 0.8,
            dashPattern: const [3, 3],
            radius: Radius.circular(20.r),
            color: showValidation
                ? const Color(0xffD93F21)
                : const Color(0xff8D8D8D),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20.r),
              child: TextField(
                controller: controller,
                autofocus: true,
                enabled: !isLoading,
                textInputAction: TextInputAction.done,
                keyboardType: TextInputType.name,
                textAlignVertical: TextAlignVertical.center,
                onSubmitted: (_) => isLoading ? null : onContinue(),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xffFFFFFF),
                  hintText: LocaleKeys.enter_your_name_exact_id.tr(),
                  hintStyle: context.textTheme.displayMedium?.mq.copyWith(
                    color: const Color(0xffC4C2C2),
                    fontSize: 14.sp,
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 18.w,
                    vertical: 22.h,
                  ),
                  border: InputBorder.none,
                  suffixIcon: isLoading
                      ? Padding(
                          padding: EdgeInsets.all(14.w),
                          child: SizedBox(
                            width: 40.w,
                            height: 20.w,
                            child: RDBLoader(
                              size: 20.h,
                              color: const Color(0xff1D1D1D),
                            ),
                          ),
                        )
                      : canContinue
                      ? Padding(
                          padding: EdgeInsets.all(8.w),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(14),
                              onTap: onContinue,
                              child: SizedBox(
                                width: 40.w,
                                height: 20.w,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    RotatedBox(
                                      quarterTurns: LanguageService.rtl ? 2 : 0,
                                      child: SvgPicture.asset(
                                        AppAssets.submitArrowSvg,
                                        width: 10,
                                        height: 20,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        )
                      : null,
                ),
              ),
            ),
          ),
        ),
        if (showValidation) ...[
          8.verticalSpace,
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            child: Text(
              LocaleKeys.name_must_be_at_least_6_characters.tr(),
              style: context.textTheme.titleLarge?.rq.copyWith(
                color: const Color(0xffD93F21),
                fontSize: 12.sp,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
