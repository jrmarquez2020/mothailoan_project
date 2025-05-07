import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:mothailoan/firebase_options.dart';
import 'package:mothailoan/screens/auth/login_screen.dart';
import 'package:mothailoan/screens/auth/sign_up_screen.dart';
import 'package:mothailoan/screens/user/user_home_screen.dart';
import 'package:mothailoan/screens/admin/admin_home_screen.dart';
import 'package:mothailoan/screens/user/dashboard_screen.dart';
import 'package:mothailoan/screens/user/motor_details_screen.dart';
import 'package:mothailoan/screens/user/motor.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Thai Motor Loan',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Colors.black,
        hintColor: Colors.white,
        scaffoldBackgroundColor: Colors.white,
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.black),
          bodyMedium: TextStyle(color: Colors.black),
        ),
      ),
      // Instead of initialRoute, use home to gate based on auth state:
      home: const AuthGate(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const SignUpScreen(),
        '/user_home': (context) => const UserHomeScreen(),
        '/admin_home': (context) => const AdminHomeScreen(),
        '/dashboard': (context) => const DashboardScreen(),
        '/motorDetails':
            (context) => MotorDetailsScreen(
              motor: Motor(
                id: "1",
                name: "Default Motor",
                type: "Drag Bike",
                price: 100000,
                dueDate: "12/2024",
                imageUrl:
                    "https://res.cloudinary.com/demo/image/upload/sample.jpg",
              ),
            ),
      },
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, authSnap) {
        if (authSnap.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final user = authSnap.data;
        if (user == null) {
          // Not signed in
          return const LoginScreen();
        }
        // Signed in — now fetch user role from Firestore
        return FutureBuilder<DocumentSnapshot>(
          future:
              FirebaseFirestore.instance
                  .collection('users')
                  .doc(user.uid)
                  .get(),
          builder: (context, userSnap) {
            if (userSnap.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }
            if (userSnap.hasError ||
                !userSnap.hasData ||
                !userSnap.data!.exists) {
              // Fallback if no user doc
              return const UserHomeScreen();
            }
            final role = userSnap.data!['role'] as String?;
            if (role == 'admin') {
              return const AdminHomeScreen();
            } else {
              return const UserHomeScreen();
            }
          },
        );
      },
    );
  }
}
