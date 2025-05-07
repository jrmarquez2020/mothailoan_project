import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'motor.dart';
import 'motor_details_screen.dart';
import 'profile.dart';
import 'motor_list.dart';

class UserHomeScreen extends StatefulWidget {
  const UserHomeScreen({super.key});

  @override
  _UserHomeScreenState createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends State<UserHomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _viewDetails(Motor motor) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MotorDetailsScreen(motor: motor)),
    );
  }

  Stream<List<Motor>> getMotorsByType(String type) {
    return FirebaseFirestore.instance
        .collection('motors')
        .where('type', isEqualTo: type)
        .snapshots()
        .map((snapshot) => snapshot.docs.map(Motor.fromDocument).toList());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('MOTHAILOAN', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.black,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.grey,
          tabs: const [
            Tab(icon: Icon(Icons.motorcycle), text: 'DRAG BIKES'),
            Tab(icon: Icon(Icons.motorcycle), text: 'MOTOR SHOWS'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildMotorStream('Drag Bikes'),
          _buildMotorStream('Motor Shows'),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.black,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: const Icon(Icons.home, color: Colors.white),
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(Icons.dashboard, color: Colors.white),
              onPressed: () {
                Navigator.pushNamed(context, '/dashboard');
              },
            ),
            IconButton(
              icon: const Icon(Icons.person, color: Colors.white),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProfileScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMotorStream(String type) {
    return StreamBuilder<List<Motor>>(
      stream: getMotorsByType(type),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.white),
          );
        }
        if (snapshot.hasError) {
          return const Center(
            child: Text(
              'Error loading motors',
              style: TextStyle(color: Colors.red),
            ),
          );
        }
        final motors = snapshot.data ?? [];
        if (motors.isEmpty) {
          return const Center(
            child: Text(
              'No motors available.',
              style: TextStyle(color: Colors.white),
            ),
          );
        }
        return MotorList(motors: motors, onViewDetails: _viewDetails);
      },
    );
  }
}
