import 'package:flutter/material.dart';

import '../constants/others.dart';
import '../constants/sizes.dart';

void showCustomSnackBar({
  required BuildContext context,
  required String message,
  required bool isSuccess,
  bool isCentered = true,
}) {
  final snackBar = SnackBar(
    content: Text(
      textAlign: isCentered ? TextAlign.center : TextAlign.left,
      message,
      style: TextStyle(
        color: Colors.white,
        fontSize: TextSizes.TITLE_SMALL,
        fontWeight: FontWeight.w500,
      ),
    ),
    backgroundColor:
        isSuccess
            ? COLORS
                .SUCCESS_COLOR // success background
            : COLORS.ERROR_COLOR, // error background,
    behavior: SnackBarBehavior.floating,
    elevation: 4,
    duration: const Duration(seconds: 1),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  );

  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(snackBar);
}

// ignore: non_constant_identifier_names
void CustomSnackBarWithWidth({
  required BuildContext context,
  required double width,
  required String message,
  required bool isSuccess,
}) {
  final double screenWidth = MediaQuery.of(context).size.width;

  final snackBar = SnackBar(
    // Does not take up full screen
    behavior: SnackBarBehavior.floating,
    backgroundColor: Colors.transparent,
    elevation: 0,
    duration: const Duration(seconds: 2),
    content: Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      // Adjust width
      margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.0001),
      decoration: BoxDecoration(
        color: isSuccess ? const Color(0xFFD4EDDA) : const Color(0xFFF8D7DA),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        message,
        style: TextStyle(
          fontSize: 16,
          color: isSuccess ? const Color(0xFF155724) : const Color(0xFF721C24),
        ),
        textAlign: TextAlign.center,
      ),
    ),
  );

  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(snackBar);
}
