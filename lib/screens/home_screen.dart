import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = AuthService();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Home"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await auth.signOut();
              // AuthGate auto routes back to Login
            },
          )
        ],
      ),
      body: Center(
        child: Text("Logged in as: ${auth.currentUser?.email ?? ""}"),
      ),
    );
  }
}
