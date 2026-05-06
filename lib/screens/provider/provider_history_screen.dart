import 'package:flutter/material.dart';

class ProviderHistoryScreen extends StatefulWidget {
  const ProviderHistoryScreen({super.key});

  @override
  State<ProviderHistoryScreen> createState() => _ProviderHistoryScreenState();
}

class _ProviderHistoryScreenState extends State<ProviderHistoryScreen> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
            "Provider History"
        ),
      ),
    );
  }
}
