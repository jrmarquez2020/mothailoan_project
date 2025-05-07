import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  // Get total users from 'users' collection
  Future<int> _getTotalUsers() async {
    var userSnapshot =
        await FirebaseFirestore.instance.collection('users').get();
    print('Total Users: ${userSnapshot.docs.length}');
    return userSnapshot.docs.length;
  }

  // Get total motors from 'motors' collection
  Future<int> _getTotalMotors() async {
    var motorsSnapshot =
        await FirebaseFirestore.instance.collection('motors').get();
    print('Total Motors: ${motorsSnapshot.docs.length}');
    return motorsSnapshot.docs.length;
  }

  // Get total loans from 'loans' collection (all loans, no filter)
  Future<int> _getTotalLoans() async {
    var loansSnapshot =
        await FirebaseFirestore.instance.collection('loaned_motors').get();
    print('Total Loans: ${loansSnapshot.docs.length}');
    return loansSnapshot.docs.length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Reports', style: TextStyle(color: Colors.white)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: FutureBuilder(
            future: Future.wait([
              _getTotalUsers(),
              _getTotalMotors(),
              _getTotalLoans(),
            ]),
            builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                );
              }

              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    'Error: ${snapshot.error}',
                    style: const TextStyle(color: Colors.redAccent),
                  ),
                );
              }

              if (snapshot.hasData) {
                final totalUsers = snapshot.data![0];
                final totalMotors = snapshot.data![1];
                final totalLoans = snapshot.data![2];

                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Reports Summary',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 30),
                    _buildReportCard(
                      'Total Motors Added',
                      totalMotors.toString(),
                    ),
                    const SizedBox(height: 10),
                    _buildReportCard('Total Users', totalUsers.toString()),
                    const SizedBox(height: 10),
                    _buildReportCard(
                      'Total Loans Loaned',
                      totalLoans.toString(),
                    ),
                  ],
                );
              }

              return const Center(
                child: Text(
                  'No data available',
                  style: TextStyle(color: Colors.white),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildReportCard(String title, String value) {
    return Card(
      color: Colors.white10,
      child: ListTile(
        title: Text(title, style: const TextStyle(color: Colors.white70)),
        trailing: Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
