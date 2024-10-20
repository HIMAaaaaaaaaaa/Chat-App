import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_chat_app/Login.dart';

class SignupScreen extends StatefulWidget {
  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController fullNameController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email address.';
    }
    if (!RegExp(r"^[a-zA-Z0-9.a-z_+]*@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$")
        .hasMatch(value)) {
      return 'Please enter a valid email address.';
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password.';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters long.';
    }
    return null;
  }

  String? validateFullName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your full name.';
    }
    return null;
  }

  Future<void> signUpWithEmailAndPassword(
    String email,
    String password,
    String name,
    String photoUrl,
    String phoneNumber,
  ) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await _firestore.collection('users').doc(userCredential.user?.uid).set({
        'uid': userCredential.user?.uid,
        'email': email,
        'fullName': name,
        'password': password,
        'photoUrl': photoUrl,
        'phoneNumber': phoneNumber,
      });
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text('Sign up'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Center(
                child: Text(
                  'Sign up',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: MediaQuery.of(context).size.width * 0.08,
                    fontFamily: "LilitaOne",
                  ),
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.02),
              Text(
                'Welcome! Please enter your Name, email, and password to create your account.',
                style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.04),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.03),
              TextField(
                textInputAction: TextInputAction.next,
                controller: fullNameController,
                decoration: InputDecoration(
                  labelText: 'Full Name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(48),
                    borderSide: BorderSide(
                      color: validateFullName(fullNameController.text) != null
                          ? Colors.red
                          : Colors.black,
                    ),
                  ),
                  errorText: validateFullName(fullNameController.text),
                ),
              ),
              SizedBox(height: 10),
              TextField(
                textInputAction: TextInputAction.next,
                controller: emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(48),
                    borderSide: BorderSide(
                      color: validateEmail(emailController.text) != null
                          ? Colors.red
                          : Colors.black,
                    ),
                  ),
                  errorText: validateEmail(emailController.text),
                ),
              ),
              SizedBox(height: 10),
              TextField(
                textInputAction: TextInputAction.next,
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(48),
                    borderSide: BorderSide(
                      color: validatePassword(passwordController.text) != null
                          ? Colors.red
                          : Colors.black,
                    ),
                  ),
                  errorText: validatePassword(passwordController.text),
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: confirmPasswordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Confirm Password',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(48),
                    borderSide: BorderSide(
                      color: (confirmPasswordController.text !=
                              passwordController.text)
                          ? Colors.red
                          : Colors.black,
                    ),
                  ),
                  errorText: (confirmPasswordController.text !=
                          passwordController.text)
                      ? 'Passwords do not match.'
                      : null,
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.02),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      String? emailError = validateEmail(emailController.text);
                      String? passwordError = validatePassword(passwordController.text);
                      String? fullNameError = validateFullName(fullNameController.text);

                      if (emailError != null ||
                          passwordError != null ||
                          fullNameError != null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20)),
                            content: Text(
                              '$emailError\n$passwordError\n$fullNameError',
                              style: TextStyle(color: Colors.black),
                            ),
                            backgroundColor: Colors.grey[350],
                          ),
                        );
                        return;
                      }
                      if (passwordController.text !=
                          confirmPasswordController.text) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20)),
                            content: Text(
                              'Passwords do not match.',
                              style: TextStyle(color: Colors.black),
                            ),
                            backgroundColor: Colors.grey[350],
                          ),
                        );
                        return;
                      }

                      try {
                        await signUpWithEmailAndPassword(
                          emailController.text,
                          passwordController.text,
                          fullNameController.text,
                          "", // Image Url
                          "", // Phone Number
                        );

                        Navigator.pushReplacementNamed(context, '/Login');
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20)),
                            content: Text(
                              'Sign up failed: $e',
                              style: TextStyle(color: Colors.black),
                            ),
                            backgroundColor: const Color.fromARGB(255, 163, 160, 159),
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 15, horizontal: 120),
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Text(
                      'Sign Up',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.02),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Already have an account? ",
                    style: TextStyle(
                      fontSize: MediaQuery.of(context).size.width * 0.04,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => LoginScreen()),
                      );
                    },
                    child: Text(
                      'Login',
                      style: TextStyle(
                        decoration: TextDecoration.underline,
                        decorationThickness: 1,
                        color: Colors.black,
                        fontSize: MediaQuery.of(context).size.width * 0.04,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}