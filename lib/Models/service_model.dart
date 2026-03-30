import 'package:flutter/material.dart';

import '../Theme/theme.dart';

class Service {
  final String title;
  final IconData icon;

  Service({
    required this.title,
    required this.icon,
  });
}



List<Service> servicesList = [
  Service(title: "Repairs", icon: Icons.build),
  Service(title: "Plumbers", icon: Icons.plumbing),
  Service(title: "Yard Work", icon: Icons.grass),
  Service(title: "Cleaning", icon: Icons.cleaning_services),
  Service(title: "HVAC", icon: Icons.ac_unit),
];


class ServiceCard extends StatelessWidget {
  final Service service;

  const ServiceCard({super.key, required this.service});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 90,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            service.icon,
            size: 30,
            color: AppColors.blue,
          ),
          const SizedBox(height: 8),
          Text(
            service.title,
            style: const TextStyle(fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}