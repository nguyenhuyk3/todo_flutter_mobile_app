import 'package:flutter/material.dart';

import '../../../../core/constants/others.dart';

class HomeBottomNavBar extends StatelessWidget {
  const HomeBottomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      color: COLORS.PRIMARY_BG,
      shape: const CircularNotchedRectangle(),
      notchMargin: 10,
      height: 80,
      elevation: 10,
      shadowColor: COLORS.PRIMARY_SHADOW,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.home_filled, size: 28),
            // Active button color
            color: COLORS.PRIMARY_APP,
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.calendar_today_outlined, size: 24),
            color: COLORS.PRIMARY_APP,
          ),

          // Spacer để chừa chỗ cho FloatingActionButton
          const SizedBox(width: 48),

          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.assignment_outlined, size: 26),
            color: COLORS.PRIMARY_APP,
          ),

          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.person_outline, size: 28),
            color: COLORS.PRIMARY_APP,
          ),
        ],
      ),
    );
  }
}
