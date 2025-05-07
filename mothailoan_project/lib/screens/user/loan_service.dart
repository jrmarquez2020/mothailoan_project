import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mothailoan/screens/user/motor.dart';

class LoanService {
  static final LoanService _instance = LoanService._internal();
  final List<Motor> _loanedMotors = [];

  final CollectionReference _loanedMotorsRef = FirebaseFirestore.instance
      .collection('loaned_motors');

  factory LoanService() {
    return _instance;
  }

  LoanService._internal();

  Future<void> loanMotor(Motor motor) async {
    try {
      _loanedMotors.add(motor); // Add locally
      print('Motor added locally: ${motor.name}');

      // Now also add to Firestore
      await _loanedMotorsRef.add({
        'name': motor.name,
        'type': motor.type,
        'price': motor.price,
        'dueDate': motor.dueDate,
        'imageUrl': motor.imageUrl ?? '',
        'loanedAt':
            FieldValue.serverTimestamp(), // Optional: to track loan date
      });

      print('Motor added to Firestore: ${motor.name}');
    } catch (e) {
      print('Error adding motor to Firestore: $e');
    }
  }

  List<Motor> getLoanedMotors() {
    print('Fetching loaned motors locally: $_loanedMotors');
    return _loanedMotors;
  }

  double getBalance() {
    return _loanedMotors.fold(0, (sum, motor) => sum + motor.price);
  }

  double getLoanPaid() {
    return 0.0; // Placeholder
  }

  double getInterestPaid() {
    return 0.0; // Placeholder
  }

  int getLoanPeriod() {
    return 0; // Placeholder
  }
}
