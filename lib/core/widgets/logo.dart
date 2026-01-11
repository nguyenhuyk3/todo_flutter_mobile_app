import 'package:flutter/material.dart';

import '../constants/others.dart';
import '../constants/sizes.dart';

class Logo extends StatelessWidget {
  const Logo({super.key});

  @override
  Widget build(BuildContext context) {
    final Color logoColor = COLORS.PRIMARY_APP_COLOR;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              '3B',
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: logoColor,
              ),
            ),

            SizedBox(width: 8),

            Text(
              'Planner',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w600,
                color: logoColor,
              ),
            ),
          ],
        ),

        const SizedBox(height: X_MIN_HEIGHT_SIZED_BOX),

        Text(
          'PRODUCTIVITY',
          style: TextStyle(fontSize: 12, color: logoColor, letterSpacing: 2),
        ),
      ],
    );
  }
}
