import 'package:depi_gp/Screens/home_screen.dart';
import 'package:depi_gp/Screens/login_screen.dart';
import 'package:depi_gp/Screens/onboarding_screen.dart';
import 'package:depi_gp/Screens/screens.dart';
import 'package:flutter/material.dart';
import 'Screens/signup_screen.dart';
import 'Theme/theme.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      home: SignupScreen(),
    );
  }
}