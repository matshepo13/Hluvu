import 'package:flutter/material.dart';

class DangerZoneMarker extends StatelessWidget {
  final String? description;
  final VoidCallback onTap;

  const DangerZoneMarker({
    Key? key,
    required this.description,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.red,
        ),
        child: const Icon(
          Icons.warning,
          color: Colors.white,
        ),
      ),
    );
  }
}