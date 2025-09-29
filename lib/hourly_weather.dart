import 'package:flutter/material.dart';

class HourlyWeather extends StatelessWidget {
  final String time;
  final IconData icon;
  final String value;

  const HourlyWeather({
    super.key,
    required this.icon,
    required this.time,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Card(
        elevation: 8,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Text(
                time,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(
                height: 8,
              ),
              Icon(
                icon,
                size: 32,
              ),
              SizedBox(
                height: 8,
              ),
              Text(
                value,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
