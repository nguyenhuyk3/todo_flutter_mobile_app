import 'package:flutter/material.dart';

import '../constants/others.dart';
import '../constants/sizes.dart';

import 'logo.dart';

/*
  constraints: const BoxConstraints() trong IconButton là để bỏ kích thước mặc định của IconButton.
  👉 NÊN dùng khi:
    - Icon phụ
    - Icon trang trí
    - Icon trong form / list item

  Align là widget dùng để căn chỉnh vị trí của 1 widget con bên trong vùng không gian mà nó được cấp.
  👉 Align = đặt con ở đâu trong khung của cha

  BoxDecoration là gì?
  👉 Dùng để trang trí cho Container:
    - nền
    - bo góc
    - viền
    - đổ bóng

  BoxShadow dùng để làm gì?
  👉 Tạo bóng đổ (shadow) phía sau widget

  blurRadius là gì?
  📌 Độ mờ / độ lan của bóng
    - Giá trị càng lớn → bóng mềm, loang, nhẹ
    - Giá trị nhỏ → bóng gắt, sắc cạnh

  offset là gì?
  👉 Vị trí lệch của bóng so với widget

  InkWell trong Flutter là widget dùng để bắt sự kiện chạm (tap) và tạo hiệu ứng 
  gợn sóng (ripple effect) theo phong cách Material Design.
    Hiểu ngắn gọn 👇
    InkWell = vùng có thể bấm + hiệu ứng sóng nước
    InkWell dùng để làm gì?
      ✔️ Bắt tap
      ✔️ Hiệu ứng ripple khi chạm
*/
class AuthenticationForm extends StatelessWidget {
  final Widget child;
  final bool allowBack;
  final String title;
  final bool resizeToAvoidBottomInset;
  final VoidCallback? onBack;

  const AuthenticationForm({
    super.key,
    required this.child,
    this.allowBack = false,
    required this.title,
    this.resizeToAvoidBottomInset = false,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      backgroundColor: COLORS.PRIMARY_BG,
      body: SafeArea(
        child: Stack(
          children: [
            if (allowBack)
              Positioned(
                left: 15,
                top: HEIGTH_SIZED_BOX_12,
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

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: HEIGTH_SIZED_BOX_12 * (allowBack ? 6 : 4)),

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

                  Expanded(child: child),

                  const SizedBox(height: HEIGTH_SIZED_BOX_12 * 1.5),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
