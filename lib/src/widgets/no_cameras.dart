import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class NoCameras extends StatelessWidget {
  const NoCameras({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          PhosphorIconsRegular.cameraSlash,
          size: 128,
          color: Colors.white.withOpacity(.54),
        )
      ],
    );
  }
}
