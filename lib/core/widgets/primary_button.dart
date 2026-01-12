// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

import '../constants/others.dart';
import '../constants/sizes.dart';

/*
    Trong Flutter, ElevatedButton là widget nút bấm chuẩn theo Material Design, 
  dùng để kích hoạt hành động chính (primary action) trong giao diện.
    ElevatedButton = nút bấm nổi, có shadow, thể hiện hành động quan trọng nhất trên màn hình.
*/
class PrimaryButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String title;
  final bool isLoading;
  final double? width;
  final IconData? icon;

  const PrimaryButton({
    super.key,
    required this.onPressed,
    required this.title,
    this.isLoading = false,
    this.width,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    // Xác định xem nút có đang bị disable hay không
    final bool isDisabled = onPressed == null || isLoading;

    return Container(
      width: width ?? double.infinity,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
      child: ElevatedButton(
        onPressed: isDisabled ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: COLORS.PRIMARY_BUTTON,
          disabledBackgroundColor: COLORS.PRIMARY_BUTTON.withOpacity(0.5),
          foregroundColor: Colors.white,
          minimumSize: Size(
            double.infinity,
            MediaQuery.sizeOf(context).height * 0.062,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation:
              1.5, // Sử dụng nếu không có thuộc tính boxShadow từ BoxDecoration
          padding: const EdgeInsets.symmetric(horizontal: 24),
          // Hiệu ứng loang khi nhấn (Ripple effect)
          // tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child:
            isLoading
                ? SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Colors.white,
                  ),
                )
                : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (icon != null) ...[
                      Icon(
                        icon,
                        size: IconSizes.ICON_20,
                        color: COLORS.PRIMARY_TEXT,
                      ),

                      const SizedBox(width: WIDTH_SIZED_BOX_4 * 2),
                    ],

                    Text(
                      title,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: TextSizes.TITLE_18,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.7, // Dùng để giãn chữ theo chiều ngang
                      ),
                    ),
                  ],
                ),
      ),
    );
  }
}
