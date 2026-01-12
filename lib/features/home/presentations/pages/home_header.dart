import 'package:flutter/material.dart';

import '../../../../core/constants/others.dart';
import '../../../../core/constants/sizes.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Avatar
        CircleAvatar(
          radius: 26,
          backgroundColor: Colors.orange.shade100,
          backgroundImage: const NetworkImage(
            "https://i.pravatar.cc/150?img=11",
          ),
        ),

        const SizedBox(width: HEIGTH_SIZED_BOX_12),

        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  "Hi, Bruce",
                  style: TextStyle(
                    fontSize: HeaderSizes.HEADER_24,
                    fontWeight: FontWeight.bold,
                    color: COLORS.PRIMARY_TEXT,
                  ),
                ),

                const SizedBox(width: WIDTH_SIZED_BOX_4),

                const Text(
                  "👋",
                  style: TextStyle(fontSize: HeaderSizes.HEADER_24),
                ),
              ],
            ),

            const SizedBox(height: HEIGHT_SIZED_BOX_4),

            Text(
              "Your daily adventure starts now",
              style: TextStyle(
                fontSize: TextSizes.TITLE_12,
                color: COLORS.SECONDARY_TEXT,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),

        const Spacer(),

        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                // ignore: deprecated_member_use
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(Icons.grid_view, color: COLORS.ICON_PRIMARY),
        ),
      ],
    );
  }
}
