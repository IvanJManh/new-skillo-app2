import 'package:flutter/material.dart';
import 'package:newskilloapp/pages/home_page.dart';
import 'package:newskilloapp/pages/sign_up_page.dart';
import 'package:newskilloapp/pages/skill_notifier.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});
  
  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage>{
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _errorText;
  SkillNotifier skillNotifier = SkillNotifier();

  void _checkPassword(){
    if(_passwordController.text != _passwordController.text){
      setState(() {
        _errorText = 'Passwords is incorrect';
      });
   
    }else{
      setState(() {
        _errorText = null;
      });
    }
  }
  void _checkEmail(){
    if(_emailController.text != _emailController.text){
      setState(() {
        _errorText = 'Email is not found';
      });
    }
    else{
      setState(() {
        _errorText = null;
      });
    }
  }
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        toolbarHeight: 150,
        automaticallyImplyLeading: false,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('lib/images/background.png'),
              fit: BoxFit.cover,
            ),
          ),

          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: const [
                Text(
                  'Welcome back',
                  style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                SizedBox(height: 0),
                Text(
                  "Let's start our journey. Learn one skill a day, stay consistent.",
                  style: TextStyle(
                    fontSize: 13.5, 
                    color: Colors.white),
                ),
              ],
            ),
          ),
        ),
      ),

        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              TextField(
                onChanged: (value) => _checkEmail(),
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Enter your email',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),

              const SizedBox(height: 20),
              TextField(
                controller: _passwordController,
                onChanged: (value) => _checkPassword(),
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Enter your password',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),

              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {

                  },
                  child: const Text(
                    'Forgot Password?',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color.fromARGB(255, 0, 130, 167),
                    ),
                  ),
                ),
              ),
              
              SizedBox(width: double.infinity,
              height: 45,
              child: ElevatedButton(
                  onPressed: _errorText != null ? null : () async{
                  Navigator.push(
                    context, MaterialPageRoute(builder: (context) => HomePage(skillNotifier: skillNotifier, userName: '', userEmail: '',)));
                }, 
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromARGB(255, 71, 172, 200),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadiusGeometry.circular(30),
                  )

                ), 
                child: const Text(
                  'Sign In',
                  style: TextStyle(
                    color: Color.fromARGB(255, 255, 255, 255),
                    fontSize: 16
                  ),

                ),
              ),
              ),
              

              const SizedBox(height: 190),
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Don't have an account? "),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const SignUpPage()),
                        );
                      },
                      child: const Text(
                        'Sign Up',
                        style: TextStyle(
                          color: Color.fromARGB(255, 0, 130, 167),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
  }
}

