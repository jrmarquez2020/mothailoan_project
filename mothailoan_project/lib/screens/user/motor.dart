import 'package:cloud_firestore/cloud_firestore.dart';

class Motor {
  final String id;
  final String name;
  final String type;
  final double price;
  final String dueDate;
  final String imageUrl;

  Motor({
    required this.id,
    required this.name,
    required this.type,
    required this.price,
    required this.dueDate,
    required this.imageUrl,
  });

  factory Motor.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;

    if (data == null) {
      throw StateError('Document data is null for motor ID: ${doc.id}');
    }

    return Motor(
      id: doc.id,
      name: data['name']?.toString() ?? '',
      type: data['type']?.toString() ?? '',
      price: _parsePrice(data['price']),
      dueDate: data['dueDate']?.toString() ?? '',
      imageUrl: data['imageUrl']?.toString() ?? '',
    );
  }

  static double _parsePrice(dynamic value) {
    if (value is int) return value.toDouble();
    if (value is double) return value;
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'type': type,
      'price': price,
      'dueDate': dueDate,
      'imageUrl': imageUrl,
    };
  }
}
