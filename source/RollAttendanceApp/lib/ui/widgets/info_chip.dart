import 'package:flutter/material.dart';

class InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final int count;
  final Color color;

  const InfoChip({
    Key? key,
    required this.icon,
    required this.label,
    required this.count,
    this.color = Colors.blue,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(icon, color: Colors.white, size: 16),
      label: Text('$label: $count'),
      backgroundColor: color,
      labelStyle: const TextStyle(color: Colors.white),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    );
  }
}
