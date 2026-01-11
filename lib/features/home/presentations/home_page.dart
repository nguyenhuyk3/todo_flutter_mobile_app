import 'package:flutter/material.dart';

import '../../../core/constants/others.dart';
import '../../../core/constants/sizes.dart';
import 'pages/home_bottom_nav_bar.dart';
import 'pages/home_header.dart';
import 'pages/home_recent_task_list.dart';
import 'pages/home_status_grid.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: COLORS.PRIMARY_BG_COLOR,
      body: SafeArea(
        bottom: false, // Để Custom Navigation Bar xử lý phần đáy
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const HomeHeader(),

                    const SizedBox(height: MAX_HEIGTH_SIZED_BOX * 2),

                    const HomeStatusGrid(),

                    const SizedBox(height: MAX_HEIGTH_SIZED_BOX * 2),

                    const HomeRecentTaskList(),

                    // Khoảng trống dưới cùng để không bị che bởi BottomNav
                    const SizedBox(height: MAX_HEIGTH_SIZED_BOX * 1.5),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const HomeBottomNavBar(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: COLORS.PRIMARY_APP_COLOR,
        elevation: 4,
        shape: const CircleBorder(),
        child: Icon(
          Icons.add,
          color: Colors.white,
          size: IconSizes.ICON_HEADER_SIZE,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
