import 'package:flutter/material.dart';

class AdditionalInfoItem extends StatelessWidget {
  final IconData icon;
  final String condition;
  final String value;
  const AdditionalInfoItem({
    super.key,
    required this.condition,
    required this.icon,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(
          icon,
          size: 32,
        ),
        SizedBox(
          height: 10,
        ),
        Text(condition),
        SizedBox(
          height: 10,
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
