import 'package:flutter/material.dart';
import 'package:taxi/core/utils/app_assets.dart';

class SplashViewBody extends StatelessWidget {
  static const String id = 'splash';
  const SplashViewBody({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage(AppAssets.splash),
          fit: BoxFit.cover,
        ),
      ),
      child: SizedBox(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Image.asset(AppAssets.splashLogo),
        ),
      ),
    );
  }
}