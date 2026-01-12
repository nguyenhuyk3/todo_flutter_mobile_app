import 'package:flutter/material.dart';

import '../../../../core/constants/others.dart';
import '../../../../core/constants/sizes.dart';

class HomeRecentTaskList extends StatelessWidget {
  const HomeRecentTaskList({super.key});

  @override
  Widget build(BuildContext context) {
    final tasks = [
      {
        "title": "Website for Rune.io",
        "progress": 0.4,
        "color": const Color(0xFFFF6B5B), // Red
      },
      {
        "title": "Dashboard for ProSavvy",
        "progress": 0.75,
        "color": const Color(0xFF4CBDB2), // Teal
      },
      {
        "title": "Mobile Apps for Track.id",
        "progress": 0.5,
        "color": COLORS.PRIMARY_APP, // Yellow
      },
      {
        "title": "Website for CourierGo.com",
        "progress": 0.4,
        "color": const Color(0xFF5F9FFF), // Blue
      },
    ];

    return Column(
      children: [
        Row(
          children: [
            Text(
              "Các tác vụ gần đây",
              style: TextStyle(
                fontSize: HeaderSizes.HEADER_18,
                fontWeight: FontWeight.bold,
                color: COLORS.HEADER_PAGE,
              ),
            ),
          ],
        ),

        const SizedBox(height: HEIGTH_SIZED_BOX_12),

        ...tasks.map(
          (task) => Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: _HomeTaskItem(
              title: task["title"] as String,
              progress: task["progress"] as double,
              progressColor: task["color"] as Color,
            ),
          ),
        ),
      ],
    );
  }
}

class _HomeTaskItem extends StatelessWidget {
  final String title;
  final double progress;
  final Color progressColor;

  const _HomeTaskItem({
    required this.title,
    required this.progress,
    required this.progressColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      decoration: BoxDecoration(
        color: COLORS.PRIMARY_BG,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: COLORS.FOCUSED_BORDER_IP, width: 1),
        boxShadow: [
          BoxShadow(
            color: COLORS.PRIMARY_SHADOW,
            offset: Offset(1, 5),
            blurRadius: 0.5, // Không mờ -> Hiệu ứng khối 3D
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: TextSizes.TITLE_16,
                    fontWeight: FontWeight.w700,
                    color: COLORS.PRIMARY_TEXT,
                  ),
                ),

                const SizedBox(height: HEIGHT_SIZED_BOX_8),

                Text(
                  "Digital Product Design",
                  style: TextStyle(
                    fontSize: TextSizes.TITLE_12,
                    color: COLORS.SECONDARY_TEXT,
                  ),
                ),

                const SizedBox(height: HEIGHT_SIZED_BOX_8),

                Row(
                  children: [
                    Icon(
                      Icons.check_circle_outline,
                      size: IconSizes.ICON_16,
                      color: COLORS.PRIMARY_TEXT,
                    ),

                    const SizedBox(width: HEIGHT_SIZED_BOX_4),

                    Text(
                      "12 Tasks",
                      style: TextStyle(
                        fontSize: TextSizes.TITLE_12,
                        fontWeight: FontWeight.bold,
                        color: COLORS.PRIMARY_TEXT,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Circular Progress
          SizedBox(
            width: 50,
            height: 50,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 6,
                  backgroundColor: Colors.grey.shade200,
                  color: progressColor,
                  strokeCap: StrokeCap.round,
                ),

                Center(
                  child: Text(
                    "${(progress * 100).toInt()}%",
                    style: TextStyle(
                      fontSize: TextSizes.TITLE_12,
                      fontWeight: FontWeight.bold,
                      color: COLORS.PRIMARY_TEXT,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
