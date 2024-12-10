import 'dart:async';
import 'dart:developer';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pinput/pinput.dart';
import 'package:taxi/core/utils/app_assets.dart';
import 'package:taxi/core/utils/constants.dart';
import 'package:taxi/core/utils/magic_router.dart';
import '../../../../core/utils/app_styles.dart';
import '../../../../core/widgets/custom_icon_back.dart';
import '../../../../translations/locale_keys.g.dart';
import '../views_models/register_cubit/register_cubit.dart';

class VerifyCodeRegisterView extends StatefulWidget {
  const VerifyCodeRegisterView(
      {Key? key,
      required this.name,
      required this.phone,
      required this.pass,
      required this.confPass})
      : super(key: key);
  final String name;
  final String phone;
  final String pass;
  final String confPass;

  @override
  State<VerifyCodeRegisterView> createState() => _VerifyCodeRegisterViewState();
}

class _VerifyCodeRegisterViewState extends State<VerifyCodeRegisterView> {
  final defaultPinTheme = PinTheme(
    width: 56,
    height: 56,
    textStyle: const TextStyle(
        fontSize: 20,
        color: Color.fromRGBO(30, 60, 87, 1),
        fontWeight: FontWeight.w600),
    decoration: BoxDecoration(
      color: Colors.grey.shade300,
      borderRadius: BorderRadius.circular(30),
    ),
  );

  int timeLeft = 0;

  void _startCountDown() {
    timeLeft = 30;
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (timeLeft > 0) {
        setState(() {
          timeLeft--;
        });
      } else {
        timer.cancel();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => RegisterCubit(),
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: SingleChildScrollView(
              child: Center(
                child: Column(
                  children: [
                    SizedBox(
                      height: 32.h,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        customIconBack(
                            icon:
                                Localizations.localeOf(context).languageCode ==
                                        'en'
                                    ? Icons.keyboard_arrow_right
                                    : Icons.keyboard_arrow_left,
                            onTap: () => MagicRouter.pop()),
                      ],
                    ),
                    SizedBox(
                      // height: 130.h,
                      height: 20.h,
                    ),
                    Image.asset(AppAssets.logo),
                    SizedBox(
                      height: 27.h,
                    ),
                    Column(
                      children: [
                        Text(
                          'A code has been sent via SMS ',
                          style: FontStyles.textStyle15,
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 45.h,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CustomPinCode(
                          defaultPinTheme: defaultPinTheme,
                          confPass: widget.confPass,
                          name: widget.name,
                          pass: widget.pass,
                          phone: widget.phone,
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 20.h,
                    ),
                    timeLeft == 0
                        ? InkWell(
                            onTap: _startCountDown,
                            child: Text(LocaleKeys.resendCode.tr(),
                                style: FontStyles.textStyle13.copyWith(
                                  decoration: TextDecoration.underline,
                                )))
                        : Text(
                            "${LocaleKeys.resendCode.tr()} ( 0:${timeLeft.toString()} )",
                            style: FontStyles.textStyle13.copyWith(
                              decoration: TextDecoration.underline,
                            )),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class CustomPinCode extends StatelessWidget {
  const CustomPinCode({
    super.key,
    required this.defaultPinTheme,
    required this.name,
    required this.phone,
    required this.pass,
    required this.confPass,
  });

  final PinTheme defaultPinTheme;
  final String name;
  final String phone;
  final String pass;
  final String confPass;

  @override
  Widget build(BuildContext context) {
    // final cubit = RegisterCubit.get(context);
    return SizedBox(
      width: 300.w,
      height: 100.h,
      child: Pinput(
        length: 6,
        defaultPinTheme: defaultPinTheme,
        focusedPinTheme: defaultPinTheme.copyWith(
          decoration: defaultPinTheme.decoration!.copyWith(
            borderRadius: BorderRadius.circular(30),
            color: Colors.white,
            border: Border.all(color: kDeepBlue),
          ),
        ),
        submittedPinTheme: defaultPinTheme.copyWith(
          decoration: defaultPinTheme.decoration!.copyWith(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: kDeepBlue),
          ),
        ),
        // validator: (s) {
        //   s == '222222'
        //       ? MagicRouter.navigateTo(const ResetPasswordView())
        //       : ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        //           backgroundColor: kDeepBlue,
        //           content: Text(
        //             LocaleKeys.pinCodeIncorrect.tr(),
        //             textAlign: TextAlign.center,
        //             style: const TextStyle(fontSize: 15),
        //           ),
        //         ));
        // },
        pinputAutovalidateMode: PinputAutovalidateMode.onSubmit,
        showCursor: true,
        onCompleted: (pin) {
          // cubit.verifyOTPCode(
          //     confPass: confPass,
          //     name: name,
          //     otpCode: pin,
          //     pass: pass,
          //     phone: phone);
          log(pin);
        },
      ),
    );
  }
}
