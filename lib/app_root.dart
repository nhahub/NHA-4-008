import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_step1_screen.dart';
import 'screens/register_step2_screen.dart';
import 'screens/register_step3_screen.dart';
import 'screens/user/user_navigation_screen.dart';
import 'screens/provider/provider_navigation_screen.dart';
import 'screens/other_screens.dart';
import 'theme/app_colors.dart';



class AyKhedmaApp extends StatelessWidget {
  const AyKhedmaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ay Khedma',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Cairo',
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.teal),
        scaffoldBackgroundColor: AppColors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.navy,
          foregroundColor: AppColors.white,
          elevation: 0,
        ),
      ),
      initialRoute: '/',
      routes: {
        '/':                (_) => const SplashScreen(),
        '/login':           (_) => const LoginScreen(),
        '/register':        (_) => const RegisterStep1Screen(),
        '/register-step2':  (_) => const RegisterStep2Screen(),
        '/register-step3':  (_) => const RegisterStep3Screen(),
        '/user_navigation':     (_) => const UserNavigationScreen(),
        '/provider_navigation': (_) => const ProviderNavigationScreen(),
        '/service-details': (_) => const ServiceDetailsScreen(),
        '/request':         (_) => const RequestServiceScreen(),
        '/payment':         (_) => const PaymentScreen(),
        '/tracking':        (_) => const TrackingScreen(),
        '/rating':          (_) => const RatingScreen(),
      },
    );
  }
}