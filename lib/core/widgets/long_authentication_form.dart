import 'package:flutter/material.dart';

import '../constants/others.dart';
import '../constants/sizes.dart';

import 'logo.dart';

/*
    ** 📌 Scaffold dùng để làm gì?
    Scaffold cung cấp sẵn cấu trúc chuẩn cho một màn hình theo Material Design:
      - Thanh tiêu đề (AppBar)
      - Vùng nội dung chính (body)
      - Nút hành động nổi (FloatingActionButton)
      - Thanh điều hướng dưới (BottomNavigationBar)
      - Menu trượt (Drawer / EndDrawer)
      - SnackBar, BottomSheet, v.v.
    👉 Nhờ Scaffold, bạn không cần tự dựng layout phức tạp từ đầu.

    Trong Flutter, Stack là một widget layout dùng để xếp chồng (overlay) 
  nhiều widget lên nhau theo trục Z (trước – sau), thay vì chỉ theo hàng (Row) hay cột (Column).
    Nói đơn giản: Stack cho phép đặt widget đè lên widget khác.

    Trong Flutter, Positioned.fill là constructor rút gọn của Positioned, 
    dùng trong Stack để làm cho một widget con chiếm toàn bộ không gian của Stack.

    Trong Flutter, SingleChildScrollView là một widget cho phép cuộn (scroll) một nội dung duy nhất, 
    thường dùng khi nội dung có thể dài hơn kích thước màn hình nhưng không cần danh sách hiệu năng cao.
    SingleChildScrollView = cho phép 1 widget con được cuộn.
*/
class LongAuthenticationForm extends StatelessWidget {
  final Widget child;
  final bool allowBack;
  final String title;
  final bool resizeToAvoidBottomInset;
  final bool showLogo;
  final VoidCallback? onBack;

  const LongAuthenticationForm({
    super.key,
    required this.child,
    this.allowBack = false,
    this.showLogo = true,
    required this.title,
    // Thông thường True là tốt nhất để Scaffold tự xử lý padding bàn phím
    this.resizeToAvoidBottomInset = true,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // resizeToAvoidBottomInset: true để giao diện tự co lên khi phím hiện
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      backgroundColor: COLORS.PRIMARY_BG,
      body: SafeArea(
        child: Stack(
          children: [
            // --- 1. PHẦN NỘI DUNG CHÍNH (CHO PHÉP CUỘN) ---
            Positioned.fill(
              child: SingleChildScrollView(
                // Khi chạm và kéo sẽ tắt bàn phím
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior
                        .onDrag, // Ẩn bàn phím khi cuộn
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 8,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Khoảng trống để tránh đè lên nút Back
                      SizedBox(
                        height: HEIGTH_SIZED_BOX_12 * (allowBack ? 3 : 2),
                      ),

                      if (showLogo)
                        Align(alignment: Alignment.center, child: Logo()),

                      const SizedBox(height: HEIGTH_SIZED_BOX_12 * 3),

                      Text(
                        title,
                        style: TextStyle(
                          fontSize: HeaderSizes.HEADER_28,
                          fontWeight: FontWeight.w600,
                          color: COLORS.HEADER_PAGE,
                        ),
                      ),

                      const SizedBox(height: HEIGTH_SIZED_BOX_12),

                      child,

                      const SizedBox(height: HEIGTH_SIZED_BOX_12 * 2),
                    ],
                  ),
                ),
              ),
            ),
            // --- 2. NÚT BACK (CỐ ĐỊNH, KHÔNG CUỘN THEO NỘI DUNG) ---
            if (allowBack)
              Positioned(
                left: 15,
                top: 15,
                child: InkWell(
                  onTap: onBack ?? () => Navigator.maybePop(context),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: COLORS.PRIMARY_BG,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                      boxShadow: [
                        BoxShadow(
                          // ignore: deprecated_member_use
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.arrow_back_ios_new,
                      size: IconSizes.ICON_28,
                      color: COLORS.ICON_PRIMARY,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
