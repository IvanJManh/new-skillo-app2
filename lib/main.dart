import 'package:firebase_core/firebase_core.dart' show Firebase;
import 'package:flutter/material.dart';
import 'package:newskilloapp/pages/splashscreen_page.dart';

void main() async{
  runApp(const MyApp());
  await Firebase.initializeApp();
  WidgetsFlutterBinding.ensureInitialized();

}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}
