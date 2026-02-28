import 'package:flutter/material.dart';
import 'package:newskilloapp/pages/sign_in_page.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Future.delayed(const Duration(seconds: 2), (){
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const SignInPage())
      );
    });
        

    return Scaffold(
      backgroundColor: Color.fromARGB(255, 71, 172, 200),
      body: Column(
        children:[
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset('lib/images/IMG_2234.PNG',
                  height: 80,
                  ),
                  const SizedBox(height: 10),
                  const Text('Skillo',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 255, 255, 255),
                  ),
                  ),
                ],
              )
          ),
          ),


          const Padding(
            padding: EdgeInsets.only(bottom: 10.0),
            child: Text(
              'Learn one skill a day',
              style: TextStyle(
                fontSize: 14,
                color: Color.fromARGB(255, 255, 255, 255),
              ),
              ),
          ),
        ]
      )
    );
  }
}
