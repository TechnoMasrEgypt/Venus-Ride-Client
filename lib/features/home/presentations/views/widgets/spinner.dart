import 'package:flutter/material.dart';

class SpinImage extends StatefulWidget {
  final String imageUrl;

  SpinImage({required this.imageUrl});

  @override
  _SpinImageState createState() => _SpinImageState();
}

class _SpinImageState extends State<SpinImage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 3),
    )..repeat();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: Tween(begin: 0.0, end: 1.0).animate(_controller),
      child: Image.asset(widget
          .imageUrl), // Replace 'assets/spin_image.png' with your image asset path
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
