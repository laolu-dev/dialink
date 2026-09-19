// import 'package:dialink/src/config/router/route_names.dart';
// import 'package:dialink/src/core/core.dart';
// import 'package:dialink/src/widgets/custom_scaffold.dart';
// import 'package:flutter/gestures.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:pin_code_text_field/pin_code_text_field.dart';

// class VerifyEmailScreen extends StatefulWidget {
//   const VerifyEmailScreen({super.key, required this.email});
  
//   final String email;

//   @override
//   State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
// }

// class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
//   final TextEditingController otp = TextEditingController();

//   @override
//   void dispose() {
//     otp.dispose();
//     AppConstants.instance.closeKeyboard();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return AppScaffold(
//       child: SingleChildScrollView(
//         child: Column(
//           children: [
//             Center(
//               child: Text(
//                 "Verify Account",
//                 style: context.textTheme.displaySmall!.copyWith(
//                   fontFamily: AppConstants.instance.cooperBtFont,
//                 ),
//               ),
//             ),
//             Text(
//               "Check ${widget.email} for OTP code",
//               textAlign: TextAlign.center,
//               style: context.textTheme.titleLarge,
//             ),
//             (context.deviceSize.height * .25).verticalSpacing,
//             PinCodeTextField(
//               maxLength: 4,
//               pinBoxWidth: 50,
//               pinBoxHeight: 50,
//               pinBoxRadius: 25,
//               pinBoxBorderWidth: 2,
//               controller: otp,
//               pinBoxOuterPadding: EdgeInsets.only(right: 8),
//               hasTextBorderColor: AppColors.primary,
//               defaultBorderColor: AppColors.white,
//               pinTextStyle: context.textTheme.titleLarge
//                   ?.copyWith(fontWeight: FontWeight.w600),
//             ),
//             32.0.verticalSpacing,
//             TextButton(
//               onPressed: () {
//                 AppConstants.instance.closeKeyboard();
//                 context.router
//                     .pushNamedAndRemoveUntil(RouteName.login, (route) => false);
//               },
//               child: Text("Verify"),
//             ),
//             // 16.0.verticalSpacing,
//             (context.deviceSize.height * .32).verticalSpacing,
//             Text.rich(
//               TextSpan(
//                 text: "Did not receive code? ",
//                 style: context.textTheme.titleSmall,
//                 children: [
//                   TextSpan(
//                     text: "Resend code",
//                     style: context.textTheme.titleMedium!
//                         .copyWith(color: AppColors.primary),
//                     recognizer: TapGestureRecognizer()
//                       ..onTap = () {
//                         HapticFeedback.heavyImpact();
//                       },
//                   ),
//                 ],
//               ),
//             )
//           ],
//         ),
//       ),
//     );
//   }
// }
