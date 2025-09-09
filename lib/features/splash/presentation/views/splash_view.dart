import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'widgets/splash_view_body.dart';

class SplashView extends StatefulWidget{
  const SplashView({Key? key}) : super(key: key);



  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {

  @override
  void initState() {
    _handlePermissions(context);
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: SplashViewBody());
  }
  Future<void> _handlePermissions(BuildContext context) async {
    // Step 1: Foreground location
    final fgStatus = await Permission.location.request();

    if (fgStatus.isGranted) {
      // Step 2: Show disclosure
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          title: Text('Location Access Required'),
          content: Text(
              'This app collects your location in the background to enable [your reason here], even when the app is closed.'),
          actions: [
            TextButton(
              child: Text('Continue'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      );

      // Step 3: Request background
      final bgStatus = await Permission.locationAlways.request();

      if (bgStatus.isGranted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Background location granted')),
        );
        // Navigate to home or main screen
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Background location denied')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Foreground location denied')),
      );
    }
  }
}
