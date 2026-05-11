import 'package:flutter/material.dart';

class UserFavoriteScreen extends StatefulWidget {
  const UserFavoriteScreen({super.key});

  @override
  State<UserFavoriteScreen> createState() => _UserFavoriteScreenState();
}

class _UserFavoriteScreenState extends State<UserFavoriteScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
            "Favorites",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            fontFamily: 'Cairo',
          ),
        ),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
            "Favorite"
        ),
      ),
    );
  }
}
