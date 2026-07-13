import 'dart:developer';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taxi/features/auth/data/repos/register_repo.dart';
import '../../../../../core/utils/cache_helper.dart';
import '../../../../../core/utils/magic_router.dart';
import '../../../../../core/widgets/custom_snackbar.dart';
import '../../../../../translations/locale_keys.g.dart';
import '../../../../after_splash/presentations/views/after_splash_view.dart';
part 'register_state.dart';

class RegisterCubit extends Cubit<RegisterState> {
  RegisterCubit() : super(RegisterInitial());

  static RegisterCubit get(context) => BlocProvider.of(context);
  bool showPassword = true;
  bool showConPassword = true;
  final TextEditingController nameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final phoneNumberController = TextEditingController();
  var receivedID = '';
  final registerRepo = RegisterRepo();

  // Future<void> submitPhoneNumber() async {
  //   // emit(Loading());
  //   log('+${selectedCountry.phoneCode}${phoneNumberController.text}');
  //   var connectivityResult = await (Connectivity().checkConnectivity());
  //   if (connectivityResult != ConnectivityResult.mobile &&
  //       connectivityResult != ConnectivityResult.wifi) {
  //     showSnackBar(
  //       LocaleKeys.noInternetConnectivity.tr(),
  //     );
  //   }
  //   // log('test');
  //   if (passwordController.text.length < 8) {
  //     showSnackBar(
  //       LocaleKeys.pleaseProvideAValidPasswordShouldGreaterThan8Character.tr(),
  //     );
  //     return;
  //   }
  //   if (phoneNumberController.text.length < 10) {
  //     showSnackBar(
  //       LocaleKeys.pleaseProvideAValidPhoneNumber.tr(),
  //     );
  //     return;
  //   }
  //   if (passwordController.text != confirmPasswordController.text) {
  //     showSnackBar(
  //       LocaleKeys.PleaseEnterASimilarPassword.tr(),
  //     );
  //     return;
  //   }
  //   emit(RegisterLoading());
  //   await FirebaseAuth.instance.verifyPhoneNumber(
  //     phoneNumber: '+${selectedCountry.phoneCode}${phoneNumberController.text}',
  //     timeout: const Duration(seconds: 14),
  //     verificationCompleted: verificationCompleted,
  //     verificationFailed: verificationFailed,
  //     codeSent: codeSent,
  //     codeAutoRetrievalTimeout: codeAutoRetrievalTimeout,
  //   );
  // }

  // void verificationCompleted(PhoneAuthCredential credential) async {
  //   // log('verificationCompleted');
  //   // await signIn(credential);
  // }

  // void verificationFailed(FirebaseAuthException error) {
  //   log('verificationFailed : ${error.toString()}');
  //   showSnackBar(error.toString());
  //   emit(ErrorOccurred(errorMsg: error.toString()));
  // }

  // void codeSent(String verificationId, int? resendToken) {
  //   log('codeSent');
  //   log(verificationId);
  //   CacheHelper.saveData(key: 'receivedID', value: verificationId);
  //   MagicRouter.navigateTo(VerifyCodeRegisterView(
  //       confPass: confirmPasswordController.text,
  //       name: nameController.text,
  //       pass: passwordController.text,
  //       phone: phoneNumberController.text));
  //   emit(PhoneNumberSubmited());
  // }

  // void codeAutoRetrievalTimeout(String verificationId) {
  //   log('codeAutoRetrievalTimeout');
  // }

  // Future<void> signIn(PhoneAuthCredential credential) async {
  //   try {
  //     await FirebaseAuth.instance.signInWithCredential(credential);
  //     // register();
  //     emit(PhoneOTPVerified());
  //   } catch (error) {
  //     log("$error");
  //     emit(ErrorOccurred(errorMsg: error.toString()));
  //   }
  // }

  // Future<void> verifyOTPCode(
  //     {required String otpCode,
  //     required String name,
  //     required String phone,
  //     required String pass,
  //     required String confPass}) async {
  //   emit(PhoneNumberSubmited());
  //   PhoneAuthCredential credential = PhoneAuthProvider.credential(
  //     verificationId: CacheHelper.getData(key: 'receivedID'),
  //     smsCode: otpCode,
  //   );
  //   try {
  //     await auth.signInWithCredential(credential).then((value) async {
  //       log('User Login In Successful');
  //       register(confPass: confPass, name: name, pass: pass, phone: phone);
  //       PrintHalper.printSuccess('Done!!');
  //       PrintHalper.printSuccess(confPass);
  //       PrintHalper.printSuccess(name);
  //       PrintHalper.printSuccess(pass);
  //       PrintHalper.printSuccess(phone);

  //       emit(PhoneOTPVerified());
  //     });
  //   } catch (e) {
  //     //showSnackBar(e.toString());
  //     PrintHalper.printError(e.toString());
  //     showSnackBar(CacheHelper.getData(key: 'lang') != 'en'
  //         ? 'Otp is incorrect'
  //         : 'الكود غير صحيح');
  //   }
  // }

  // Future<void> logOut() async {
  //   await FirebaseAuth.instance.signOut();
  // }

  // User getLoggedInUser() {
  //   User firebaseUser = FirebaseAuth.instance.currentUser!;
  //   return firebaseUser;
  // }

  Future register() async {
    if (passwordController.text.length < 8) {
      showSnackBar(
        LocaleKeys.pleaseProvideAValidPasswordShouldGreaterThan8Character.tr(),
      );
      return;
    }
    if (phoneNumberController.text.length < 10) {
      showSnackBar(
        LocaleKeys.pleaseProvideAValidPhoneNumber.tr(),
      );
      return;
    }
    if (passwordController.text != confirmPasswordController.text) {
      showSnackBar(
        LocaleKeys.PleaseEnterASimilarPassword.tr(),
      );
      return;
    }
    emit(RegisterLoading());
    final res = await registerRepo.register(
        conPassword: confirmPasswordController.text,
        password: passwordController.text,
        name: nameController.text,
        phone: phoneNumberController.text);

    res.fold(
      (err) {
        
        showSnackBar(err);
        log('msg:${err.toString()}');
        emit(RegisterError());
      },
      (res) async {
        emit(RegisterLoaded());
        showSnackBar(CacheHelper.getData(key: 'lang') != 'en'
            ? res.message
            : 'Logged in successfully');
        // showSnackBar(res.message);
        // log(res.message);
        await CacheHelper.saveData(key: 'userId', value: res.data.id);
        await CacheHelper.saveData(key: 'userName', value: res.data.name);
        await CacheHelper.saveData(key: 'photo', value: res.data.photo);
        await CacheHelper.saveData(key: 'phone', value: res.data.phone);
        await CacheHelper.saveData(key: 'login', value: true);
        MagicRouter.navigateTo(const AfterSplashView());
        // submitPhoneNumber();
      },
    );
  }
}
