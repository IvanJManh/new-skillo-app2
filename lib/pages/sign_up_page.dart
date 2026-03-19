import 'package:flutter/material.dart';
//import 'package:firebase_auth/firebase_auth.dart';
import 'package:newskilloapp/pages/sign_in_page.dart';
import 'package:newskilloapp/pages/home_page.dart';
import 'package:newskilloapp/pages/skill_notifier.dart';
import 'package:newskilloapp/services/auth_service.dart';
import 'package:newskilloapp/auth.gate.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

final _nameController = TextEditingController();

class _SignUpPageState extends State<SignUpPage>{
  //final FirebaseAuth _auth = FirebaseAuth.instance;
  final _auth = AuthService();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _emailController =TextEditingController();
  bool _isLoading = false;
  String? _errorText;
<<<<<<< HEAD
=======
  SkillNotifier skillNotifier = SkillNotifier();
>>>>>>> c688dd92d791e34e91c4d3e7540ee94cb6b5fed5

  void _checkPassword(){
    if (_passwordController.text != _confirmPasswordController.text){
      setState(() {
        _errorText = "Passwords do not match";
      });
    }
    else{
      setState(() {
        _errorText = null;
      });
    }
  }

  /*Future<void> _signUp() async{
    try{
      await _auth.createUserWithEmailAndPassword(
        email: _emailController.text, 
        password: _passwordController.text);

        Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => HomePage()));

    } on FirebaseAuthException catch (e){
      print(e.message);
    }
  }*/
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        toolbarHeight: 150,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('lib/images/background.png'),
              fit: BoxFit.cover,
              )
          ),

          child: Padding(
            padding: EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  'New to this app?',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 255, 255, 255),
                  ),
                ),

                SizedBox(height: 0,),
                Text(
                  'Sign up now and learn a new skill every day.',
                  style: TextStyle(
                    color: Color.fromARGB(255, 255, 255, 255),
                    fontSize: 13.5,
                  ),
                ),
              ],

            )
            )


        ),
      ),

        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Enter your name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  )
                ),
              ),

              const SizedBox(height: 10),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Enter your email',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  )
                ),
              ),

              const SizedBox(height: 10,),
              TextField(
                obscureText: true,
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Enter your password',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),

              const SizedBox(height: 10,),
              TextField(
                obscureText: true,
                onChanged: (value) => _checkPassword(),
                controller: _confirmPasswordController,
                decoration: InputDecoration(
                  labelText: 'Confirm your password',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  errorText: _errorText,
                ),
              ),
            
              const SizedBox(height: 20),
              SizedBox(
                height: 45,
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: (_errorText != null || _isLoading) ? null : () async{
                    setState(() {
                      _isLoading = true;
                    });
                    try {
                      final cred = await _auth.signUp(
                        email: _emailController.text, 
                        password: _passwordController.text
                      );
                      
                      // Optionally update display name
                      if (_nameController.text.isNotEmpty) {
                        await cred.user?.updateDisplayName(_nameController.text);
                      }
                      
                      if (mounted) {
                        Navigator.pushAndRemoveUntil(
                          context, 
                          MaterialPageRoute(builder: (context) => const AuthGate()),
                          (route) => false
                        );
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Sign up failed: $e")),
                        );
                      }
                    } finally {
                      if (mounted) {
                        setState(() {
                          _isLoading = false;
                        });
                      }
                    }
                  }, 
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromARGB(255, 71, 172, 200),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadiusGeometry.circular(30),
                    )
                  ), child: _isLoading 
                ? const SizedBox(
                    height: 20, 
                    width: 20, 
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                  )
                : const Text(
                    'Sign up',
                    style: TextStyle(
                      color: Color.fromARGB(255, 255, 255, 255),
                      fontSize: 16,
                    ),
                  ),
                  ),
              ),

              const SizedBox(height: 90),
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Do have an account? "),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const SignInPage()),
                        );
                      },
                      child: const Text(
                        'Sign In',
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
    ),
    );
  }
}
