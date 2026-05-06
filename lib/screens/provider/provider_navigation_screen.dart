import 'package:ay_khedma/screens/provider/provider_earnings_screen.dart';
import 'package:ay_khedma/screens/provider/provider_history_screen.dart';
import 'package:ay_khedma/screens/provider/provider_home_screen.dart';
import 'package:ay_khedma/screens/provider/provider_profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:water_drop_nav_bar/water_drop_nav_bar.dart';

class ProviderNavigationScreen extends StatefulWidget {
  const ProviderNavigationScreen({super.key});

  @override
  State<ProviderNavigationScreen> createState() => _ProviderNavigationScreenState();
}

class _ProviderNavigationScreenState extends State<ProviderNavigationScreen> {

  int selectedIndex = 0;
  late PageController pageController;

  final List<Widget> screens = [
    const ProviderHomeScreen(),
    const ProviderHistoryScreen(),
    const ProviderEarningsScreen(),
    const ProviderProfileScreen(),
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
            filledIcon: Icons.history,
            outlinedIcon: Icons.history_outlined,
          ),
          BarItem(
            filledIcon: Icons.attach_money,
            outlinedIcon: Icons.attach_money_outlined,
          ),
          BarItem(
            filledIcon: Icons.person,
            outlinedIcon: Icons.person_outline,
          ),
        ],
      ),
    );
  }
}
