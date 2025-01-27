import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class LoadingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SvgPicture.asset(
            'lib/assets/Sperrstunde_Logo-zweizeilig_RGB.png',
            height: 200,
            color: Color.fromARGB(255, 255, 95, 31)),
      ),
    );
  }
}
