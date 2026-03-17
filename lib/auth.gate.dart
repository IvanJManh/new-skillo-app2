<<<<<<< HEAD
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'pages/home_page.dart';
import 'pages/sign_in_page.dart';
import 'pages/skill_notifier.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // loading
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // logged in
        if (snapshot.hasData) {
          final user = snapshot.data!;
          return HomePage(
            skillNotifier: SkillNotifier(),
            userName: user.displayName ?? "User",
            userEmail: user.email ?? "",
          );
        }

        // logged out
        return const SignInPage();
      },
    );
  }
}

=======
>>>>>>> c0f5e256288cb22504cc39a620c4e626a7082336
