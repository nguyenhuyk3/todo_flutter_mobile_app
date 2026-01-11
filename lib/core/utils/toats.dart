import 'package:delightful_toast/delight_toast.dart';
import 'package:delightful_toast/toast/components/toast_card.dart';
import 'package:delightful_toast/toast/utils/enums.dart';
import 'package:flutter/material.dart';

import '../constants/others.dart';
import '../constants/sizes.dart';

class ToastUtils {
  static void showSuccess({
    required BuildContext context,
    String message = "Thành công!",
  }) {
    _showToast(
      context: context,
      title: "Thành công",
      subtitle: message,
      icon: Icons.check_circle,
      iconColor: Colors.green,
    );
  }

  static void showError({
    required BuildContext context,
    String message = "Đã có lỗi xảy ra!",
  }) {
    _showToast(
      context: context,
      title: "Lỗi",
      subtitle: message,
      icon: Icons.error,
      iconColor: Colors.red,
    );
  }

  static void showWarning({
    required BuildContext context,
    required String message,
  }) {
    _showToast(
      context: context,
      title: "Lưu ý",
      subtitle: message,
      icon: Icons.warning,
      iconColor: Colors.orange,
    );
  }

  static void _showToast({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
  }) {
    DelightToastBar(
      autoDismiss: true, // Tự động đóng
      position: DelightSnackbarPosition.top, // Hiển thị ở trên cùng
      snackbarDuration: const Duration(seconds: 3), // Thời gian hiển thị
      builder:
          (context) => ToastCard(
            color: COLORS.PRIMARY_BG_COLOR,
            leading: Icon(
              icon,
              size: IconSizes.ICON_HEADER_SIZE,
              color: iconColor,
            ),
            title: Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: TextSizes.TITLE_SMALL,
                color: COLORS.PRIMARY_TEXT_COLOR,
              ),
            ),
            subtitle: Text(
              subtitle,
              style: TextStyle(
                fontSize: TextSizes.TITLE_X_SMALL,
                color: COLORS.SECONDARY_TEXT_COLOR,
              ),
            ),
          ),
    ).show(context); // Lệnh gọi hiển thị
  }
}
