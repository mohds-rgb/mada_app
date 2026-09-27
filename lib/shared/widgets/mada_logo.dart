import 'package:flutter/material.dart';

/// شعار MADA الرسمي (بند 4) — يُستخدم بشاشة Splash وأي مكان يحتاج الشعار.
class MadaLogo extends StatelessWidget {
  const MadaLogo({super.key, this.size = 120});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/branding/mada_app_icon_final.png',
      width: size,
      height: size,
    );
  }
}
