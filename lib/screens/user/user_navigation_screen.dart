import 'package:ay_khedma/screens/user/user_favorite_screen.dart';
import 'package:ay_khedma/screens/user/user_history_screen.dart';
import 'package:ay_khedma/screens/user/user_profile_screen.dart';
import 'package:ay_khedma/screens/user/user_setting_screen.dart';
import 'package:flutter/material.dart';
import 'package:water_drop_nav_bar/water_drop_nav_bar.dart';

import 'user_home_screen.dart';

class UserNavigationScreen extends StatefulWidget {
  const UserNavigationScreen({super.key});

  @override
  State<UserNavigationScreen> createState() => _UserNavigationScreenState();
}

class _UserNavigationScreenState extends State<UserNavigationScreen> {

  int selectedIndex = 0;
  late PageController pageController;

  final List<Widget> screens = [
    const UserHomeScreen(),
    const UserFavoriteScreen(),
    const UserHistoryScreen(),
    const UserSettingScreen(),
  ];

  @override
  void initState() {
    super.initState();
    pageController = PageController(initialPage: selectedIndex);
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold (
      body: PageView(
        controller: pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: screens,
      ),

      bottomNavigationBar: WaterDropNavBar(
        selectedIndex: selectedIndex,

        onItemSelected: (index) {
          setState(() {
            selectedIndex = index;
          });

          pageController.animateToPage(
            index,
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOutQuad,
          );
        },

        barItems: [
          BarItem(
            filledIcon: Icons.home,
            outlinedIcon: Icons.home_outlined,
          ),
          BarItem(
            filledIcon: Icons.favorite,
            outlinedIcon: Icons.favorite_border,
          ),
          BarItem(
            filledIcon: Icons.access_time_filled,
            outlinedIcon: Icons.access_time_outlined,
          ),
          BarItem(
            filledIcon: Icons.settings,
            outlinedIcon: Icons.settings_outlined,
          ),
        ],
      ),
    );
  }
}
