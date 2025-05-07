import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RepaymentScreen extends StatefulWidget {
  final Map<String, dynamic> motorData;
  final String motorId;

  const RepaymentScreen({
    super.key,
    required this.motorData,
    required this.motorId,
  });

  @override
  _RepaymentScreenState createState() => _RepaymentScreenState();
}

class _RepaymentScreenState extends State<RepaymentScreen> {
  String? selectedMethod;

  void _showSnackBar(
    BuildContext context,
    String message, {
    Color color = Colors.black,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _processRepayment(BuildContext context) async {
    try {
      // Save to "repayments"
      await FirebaseFirestore.instance.collection('repayments').add({
        'name': widget.motorData['name'],
        'price': widget.motorData['price'],
        'loanPeriod': widget.motorData['dueDate'],
        'imageUrl': widget.motorData['imageUrl'] ?? '',
        'paymentMethod': selectedMethod,
        'paidAt': FieldValue.serverTimestamp(),
      });

      // Delete from "loaned_motors"
      await FirebaseFirestore.instance
          .collection('loaned_motors')
          .doc(widget.motorId)
          .delete();

      _showSnackBar(context, 'Motor repaid successfully!');
      Navigator.pop(context); // Optionally go back
    } catch (e) {
      print('Repayment error: $e');
      _showSnackBar(context, 'Error processing repayment.', color: Colors.red);
    }
  }

  @override
  Widget build(BuildContext context) {
    final motor = widget.motorData;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'THAI MOTOR LOANED',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (motor['imageUrl'] != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(12.0),
                child: Image.network(
                  motor['imageUrl'],
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            const SizedBox(height: 20),
            Text(
              'PRICE: ₱ ${motor['price']}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'LOAN PERIOD: ${motor['dueDate']}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'REPAY VIA:',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 10),
            _buildPaymentOption(
              'GCASH',
              Icons.account_balance_wallet,
              Colors.blue,
            ),
            _buildPaymentOption('PAYPAL', Icons.payment, Colors.blue),
            _buildPaymentOption('MASTERCARD', Icons.credit_card, Colors.red),
            const SizedBox(height: 30),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
                minimumSize: const Size(double.infinity, 50),
              ),
              onPressed: () {
                if (selectedMethod != null) {
                  _processRepayment(context);
                } else {
                  _showSnackBar(
                    context,
                    'Please select a payment method.',
                    color: Colors.red,
                  );
                }
              },
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),
                child: Text(
                  'REPAY NOW',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentOption(String method, IconData icon, Color color) {
    return CheckboxListTile(
      title: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 8),
          Text(
            method,
            style: const TextStyle(color: Colors.white, fontSize: 14),
          ),
        ],
      ),
      value: selectedMethod == method,
      onChanged: (bool? value) {
        setState(() {
          selectedMethod = value == true ? method : null;
        });
      },
      activeColor: color,
      checkColor: Colors.white,
      tileColor: Colors.black,
      controlAffinity: ListTileControlAffinity.leading,
    );
  }
}
