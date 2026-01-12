import 'package:flutter/material.dart';

import '../../../../core/constants/others.dart';
import '../../../../core/constants/sizes.dart';

class HomeStatusGrid extends StatelessWidget {
  const HomeStatusGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _HomeStatusCard(
                title: "Chưa bắt đầu",
                count: "24 Tasks",
                icon: Icons.autorenew_rounded,
                bgColor: COLORS.PENDING,
                iconColor: Colors.white,
              ),
            ),

            const SizedBox(width: WIDTH_SIZED_BOX_4 * 4),

            Expanded(
              child: _HomeStatusCard(
                title: "Đang làm",
                count: "12 Tasks",
                icon: Icons.access_time_filled,
                bgColor: COLORS.IN_PROGRESS,
                iconColor: Colors.white,
              ),
            ),
          ],
        ),

        const SizedBox(height: HEIGHT_SIZED_BOX_8 * 2),

        Row(
          children: [
            Expanded(
              child: _HomeStatusCard(
                title: "Completed",
                count: "42 Tasks",
                icon: Icons.assignment_turned_in,
                bgColor: COLORS.COMPLETED,
                iconColor: Colors.white,
              ),
            ),

            const SizedBox(width: WIDTH_SIZED_BOX_4 * 4),

            Expanded(
              child: _HomeStatusCard(
                title: "Canceled",
                count: "8 Tasks",
                icon: Icons.cancel_presentation,
                bgColor: COLORS.CANCELED,
                iconColor: Colors.white,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _HomeStatusCard extends StatelessWidget {
  final String title;
  final String count;
  final IconData icon;
  final Color bgColor;
  final Color iconColor;

  const _HomeStatusCard({
    required this.title,
    required this.count,
    required this.icon,
    required this.bgColor,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: COLORS.FOCUSED_BORDER_IP, width: 1),
        boxShadow: [
          BoxShadow(
            color: COLORS.PRIMARY_SHADOW,
            offset: Offset(0, 3),
            blurRadius: 0.5,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              // ignore: deprecated_member_use
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: IconSizes.ICON_20),
          ),

          const SizedBox(height: HEIGTH_SIZED_BOX_12),

          Text(
            title,
            style: TextStyle(
              fontSize: TextSizes.TITLE_16,
              fontWeight: FontWeight.bold,
              color: COLORS.PRIMARY_TEXT,
            ),
          ),

          const SizedBox(height: HEIGHT_SIZED_BOX_4),

          Text(
            count,
            style: TextStyle(
              fontSize: TextSizes.TITLE_12,
              color: COLORS.PRIMARY_TEXT,
            ),
          ),
        ],
      ),
    );
  }
}
