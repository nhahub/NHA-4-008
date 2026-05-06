import 'package:flutter/material.dart';

class UserFavoriteScreen extends StatefulWidget {
  const UserFavoriteScreen({super.key});

  @override
  State<UserFavoriteScreen> createState() => _UserFavoriteScreenState();
}

class _UserFavoriteScreenState extends State<UserFavoriteScreen> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
            "Favorite"
        ),
      ),
    );
  }
}
