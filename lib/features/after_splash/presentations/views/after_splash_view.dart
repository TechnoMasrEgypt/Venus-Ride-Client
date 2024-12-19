import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taxi/features/home/presentations/views_models/check_ride_cubit/check_ride_cubit.dart';
import '../../../../core/widgets/custom_drawer.dart';
import 'widgets/after_splash_view_body.dart';

class AfterSplashView extends StatelessWidget {
  const AfterSplashView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CheckRideCubit(),
      child: Scaffold(
        drawer: customDrawer(context),
        body: SafeArea(child: AfterSplashViewBody()),
      ),
    );
  }
}
