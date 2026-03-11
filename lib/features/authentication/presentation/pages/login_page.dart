// import 'dart:developer';
//
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:get_it/get_it.dart';
// import 'package:go_router/go_router.dart';
// import 'package:trydos/config/theme/typography.dart';
// import 'package:trydos/core/domin/repositories/prefs_repository.dart';
// import 'package:trydos/core/utils/form_utils.dart';
// import '../../../../common/constant/countries.dart';
// import '../../../../core/utils/form_state_mixin.dart';
// import '../../../../core/utils/responsive_padding.dart';
// import '../../../../routes/router.dart';
// import '../../../../service/notification_service/notification_service/handle_notification/notification_process.dart';
// import '../../../app/app_elvated_button.dart';
// import '../../../app/app_widgets/app_text_field.dart';
// import '../../../app/app_widgets/phone_input/phone_input_widget.dart';
// import '../../../app/blocs/app_bloc/app_bloc.dart';
// import '../../../app/blocs/app_bloc/app_event.dart';
// import '../../../chat/presentation/manager/chat_bloc.dart';
// import '../../../chat/presentation/manager/chat_event.dart' as chatEvents;
// import '../manager/auth_bloc.dart';
// import 'package:trydos/core/utils/theme_state.dart';
//
// class LoginPage extends StatefulWidget {
//   const LoginPage({Key? key}) : super(key: key);
//
//   @override
//   State<LoginPage> createState() => _LoginPageState();
// }
//
//  class _LoginPageState extends ThemeState<LoginPage> with FormStateMinxin {
//   final showPasswordNotifier = ValueNotifier(true);
//   late final ValueNotifier<bool> filledPasswordNotifier;
//   late final ValueNotifier<Country?> countryNotifier;
//   String? fullPhoneToSave;
//   String? fullPhone;
//   late ChatBloc chatBloc;
//   @override
//   void initState() {
//     super.initState();
//     chatBloc = BlocProvider.of<ChatBloc>(context);
//     filledPasswordNotifier = ValueNotifier(false);
//     countryNotifier = ValueNotifier(null);
//     form.controllers[1].addListener(() {
//       filledPasswordNotifier.value = form.controllers[1].text.trim().length >= 6;
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       resizeToAvoidBottomInset: true,
//       body: Form(
//         key: form.key,
//         child: Padding(
//           padding: HWEdgeInsets.symmetric(horizontal: 20),
//           child: Column(
//             mainAxisSize: MainAxisSize.max,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               50.verticalSpace,
//               RichText(
//                 text: TextSpan(
//                   children: [
//                     TextSpan(
//                       text: 'Please enter your',
//                       style: textTheme.headlineSmall?.rr,
//                     ),
//                     TextSpan(
//                       text: 'Phone Number',
//                       style: textTheme.headlineSmall?.rr
//                           .copyWith(color: colorScheme.secondary),
//                     ),
//                   ],
//                 ),
//               ),
//               22.verticalSpace,
//                 PhoneInputField(
//                   phoneController: form.controllers[0],
//                   onInputChanged: (phone) {
//                     log('phone is $phone');
//                     log('phone is ${phone.phoneNumber!.substring(phone.dialCode!.length)}');
//                     fullPhone=phone.phoneNumber;
//                   },
//                 ),
//               10.verticalSpace,
//               BlocBuilder<AuthBloc, AuthState>(builder: (context, state) {
//                 return AppTextField(
//                   controller: form.controllers[1],
//                   enabled: state.loginToChatStatus != LoginToChatStatus.loading,
//                   hintText: 'password',
//                   contentPadding:
//                       HWEdgeInsets.symmetric(horizontal: 5),
//                   suffixIcon: ValueListenableBuilder<bool>(
//                       valueListenable: showPasswordNotifier,
//                       builder: (context, show, _) {
//                         return IconButton(
//                           icon: Icon(
//                             show
//                                 ? Icons.visibility_outlined
//                                 : Icons.visibility_off_outlined,
//                           ),
//                           onPressed: () {
//                             showPasswordNotifier.value =
//                                 !showPasswordNotifier.value;
//                           },
//                         );
//                       }),
//                 );
//               }),
//               const Spacer(),
//               BlocConsumer<AuthBloc, AuthState>(
//                 listener: (context, state) {
//                   if (state.loginToChatStatus == LoginToChatStatus.success) {
//                     if (!mounted) {
//                       return;
//                     }
//                     GetIt.I<PrefsRepository>().setPhoneNumber(fullPhoneToSave!);
//                     context.go(GRouter.config.applicationRoutes.kBasePage);
//                     chatBloc.add(const chatEvents.GetChatsEvent());
//                     BlocProvider.of<AppBloc>(context).add(ChangeBasePage(2));
//                   }
//                 },
//                 builder: (context, state) {
//                   return ValueListenableBuilder<bool>(
//                       valueListenable: filledPasswordNotifier,
//                       builder: (context, isFilledPassword, _) {
//                         return SizedBox(
//                           width: 1.sw,
//                           child: AppElevatedButton(
//                             appButtonStyle: AppButtonStyle.primary,
//                             onPressed:
//                                     isFilledPassword
//                                 ? _onLogIn
//                                 : null,
//                             text: 'Login',
//                             isLoading:
//                                 state.loginToChatStatus == LoginToChatStatus.loading,
//                           ),
//                         );
//                       });
//                   },
//               ),
//               60.verticalSpace,
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   void _onLogIn() {
//     form.key.currentState!.save();
//     final validate = form.key.currentState!.validate() && fullPhone != null;
//     if (!validate) return;
//     String fcmToken=NotificationProcess.myFcmToken!;
//     fullPhoneToSave=fullPhone;
//     BlocProvider.of<AuthBloc>(context).add(
//       LoginToChatEvent(
//           mobilePhone: fullPhone!.substring(1), password: form.controllers[1].text , fcmToken: fcmToken),
//     );
//   }
//
//   @override
//   int get numberOfFields => 2;
// }
