import 'package:flutter/material.dart';
<<<<<<< HEAD
import 'package:firebase_auth/firebase_auth.dart';
=======
>>>>>>> c35c16757c3340e41072186f3d56103199a2d013
import 'package:newskilloapp/pages/home_page.dart';
import 'package:newskilloapp/pages/sign_up_page.dart';
import 'package:newskilloapp/pages/skill_notifier.dart';
import 'package:newskilloapp/services/auth_service.dart';
import 'package:newskilloapp/auth.gate.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});
  
  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage>{
  final _auth = AuthService();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorText;
  SkillNotifier skillNotifier = SkillNotifier();

<<<<<<< HEAD
=======
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
  

>>>>>>> c35c16757c3340e41072186f3d56103199a2d013
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
<<<<<<< HEAD
=======
                onChanged: (value) => _checkEmail(),
>>>>>>> c35c16757c3340e41072186f3d56103199a2d013
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
<<<<<<< HEAD
=======
                onChanged: (value) => _checkPassword(),
>>>>>>> c35c16757c3340e41072186f3d56103199a2d013
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
<<<<<<< HEAD
                  onPressed: _isLoading ? null : () async{
=======
                  onPressed: (_errorText != null || _isLoading) ? null : () async{
>>>>>>> c35c16757c3340e41072186f3d56103199a2d013
                    setState(() {
                      _isLoading = true;
                    });
                    try {
                      await _auth.signIn(
                        email: _emailController.text, 
                        password: _passwordController.text
                      );
                      if (mounted) {
                        Navigator.pushAndRemoveUntil(
                          context, 
                          MaterialPageRoute(builder: (context) => const AuthGate()),
                          (route) => false
                        );
                      }
<<<<<<< HEAD
                    } on FirebaseAuthException catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(AuthService.handleFirebaseAuthError(e)),
                            backgroundColor: Colors.redAccent,
                          ),
                        );
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("An unexpected error occurred.")),
=======
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Sign in failed: $e")),
>>>>>>> c35c16757c3340e41072186f3d56103199a2d013
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

                ), 
                child: _isLoading 
                ? const SizedBox(
                    height: 20, 
                    width: 20, 
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                  )
                : const Text(
                  'Sign In',
                  style: TextStyle(
                    color: Color.fromARGB(255, 255, 255, 255),
                    fontSize: 16
                  ),

                ),
              ),
              ),
              

              const SizedBox(height: 150),
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

