import 'package:flutter/material.dart';

class LoadingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Image.asset(
          'lib/assets/Sperrstunde_Logo-zweizeilig_RGB.png',
          height: 200,
        ),
      ),
    );
  }
}
