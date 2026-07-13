import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:taxi/features/after_splash/presentations/views/after_splash_view.dart';
import 'package:taxi/features/onBoarding/data/presentation/view/on_boarding_view.dart';
import '../../../../../core/utils/cache_helper.dart';
import '../../../../../core/utils/magic_router.dart';
import 'widgets/splash_view_body.dart';

class SplashView extends StatefulWidget {
  const SplashView({Key? key}) : super(key: key);

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  @override
  void initState() {
    super.initState();
    _startSplashSequence();
  }

  Future<void> _startSplashSequence() async {
    // Run permission handling and the minimum splash duration together.
    // Navigation only happens once BOTH are done, so there's no race.
    await Future.wait([
      _handlePermissions(),
      Future.delayed(const Duration(seconds: 5)),
    ]);

    if (!mounted) return;
    _goNext();
  }

  void _goNext() {
    if (CacheHelper.getData(key: 'login') == true) {
      MagicRouter.navigateAndPopAll(const AfterSplashView());
    } else {
      MagicRouter.navigateAndPopAll(const OnBoardingView());
    }
  }

  Future<void> _handlePermissions() async {
    final fgStatus = await Permission.location.request();
    if (!mounted) return;

    if (fgStatus.isGranted) {
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          title: const Text('Location Access Required'),
          content: const Text(
              'This app collects your location in the background to enable [your reason here], even when the app is closed.'),
          actions: [
            TextButton(
              child: const Text('Continue'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      );
      if (!mounted) return;

      final bgStatus = await Permission.locationAlways.request();
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(bgStatus.isGranted
              ? 'Background location granted'
              : 'Background location denied'),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Foreground location denied')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: SplashViewBody());
  }
}