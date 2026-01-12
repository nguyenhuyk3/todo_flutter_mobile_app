import 'package:flutter/material.dart';

import '../constants/others.dart';
import '../constants/sizes.dart';

class ErrorDisplayer extends StatelessWidget {
  final String message;

  const ErrorDisplayer({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, left: 12),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            size: IconSizes.ICON_12,
            color: COLORS.ERROR,
          ),

          const SizedBox(width: WIDTH_SIZED_BOX_4 * 2),

          Text(
            message,
            style: TextStyle(color: COLORS.ERROR, fontSize: TextSizes.TITLE_12),
          ),
        ],
      ),
    );
  }
}
