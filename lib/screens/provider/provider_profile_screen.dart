import 'package:flutter/material.dart';

class ProviderProfileScreen extends StatefulWidget {
  const ProviderProfileScreen({super.key});

  @override
  State<ProviderProfileScreen> createState() => _ProviderProfileScreenState();
}

class _ProviderProfileScreenState extends State<ProviderProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold (
      body: Center(
        child: Text(
            "Provider Profile"
        ),
      ),
    );
  }
}
