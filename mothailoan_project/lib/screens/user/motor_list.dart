import 'package:flutter/material.dart';
import 'motor.dart';

class MotorList extends StatelessWidget {
  final List<Motor> motors;
  final Function(Motor) onViewDetails;

  const MotorList({
    super.key,
    required this.motors,
    required this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: motors.length,
      itemBuilder: (context, index) {
        final motor = motors[index];
        return Card(
          color: Colors.grey[900],
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(12),
            leading:
                motor.imageUrl.isNotEmpty
                    ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        motor.imageUrl,
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                        errorBuilder:
                            (context, error, stackTrace) => const Icon(
                              Icons.broken_image,
                              color: Colors.white,
                            ),
                      ),
                    )
                    : const Icon(Icons.motorcycle, color: Colors.white),
            title: Text(
              motor.name,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '₱${motor.price}',
                  style: const TextStyle(color: Colors.greenAccent),
                ),
                Text(
                  'Type: ${motor.type}',
                  style: const TextStyle(color: Colors.white70),
                ),
                Text(
                  'Due: ${motor.dueDate}',
                  style: const TextStyle(color: Colors.white38),
                ),
              ],
            ),
            trailing: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              onPressed: () => onViewDetails(motor),
              child: const Text('View', style: TextStyle(color: Colors.white)),
            ),
          ),
        );
      },
    );
  }
}
