import 'package:depi_gp/Screens/favorites_screen.dart';
import 'package:depi_gp/Screens/history_screen.dart';
import 'package:depi_gp/Screens/home_screen.dart';
import 'package:depi_gp/Screens/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:water_drop_nav_bar/water_drop_nav_bar.dart';


class Screens extends StatefulWidget {
  @override
  _ScreensState createState() => _ScreensState();
}

class _ScreensState extends State<Screens> {
  int selectedIndex = 0;
  late PageController pageController;

  final List<Widget> screens = [
    HomeScreen(),
    FavoritesScreen(),
    ProfileScreen(),
    HistoryScreen(),
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
    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            radius: 20,
            backgroundColor: Colors.grey,
            child: CircleAvatar(
              radius: 18,
              backgroundColor: Colors.grey.shade200,
              child: const Icon(
                Icons.person,
                size: 20,
              ),
            ),
          ),
        ),
        title: Text(
          "Username",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
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
            filledIcon: Icons.person,
            outlinedIcon: Icons.person_outline,
          ),
          BarItem(
            filledIcon: Icons.access_time_filled,
            outlinedIcon: Icons.access_time_outlined,
          ),
        ],
      ),
    );
  }
}