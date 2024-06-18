import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';



class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool _obscureText = true;

  Future<void> signInWithEmailAndPassword(String email, String password) async {
    if (email.isEmpty || password.isEmpty) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Colors.white,
            title: Text("Login Error"),
            content: Text(
              'An error occurred during sign in. Please make sure you have entered both email and password.',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            actions: <Widget>[
              TextButton(
                child: Text("OK"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
      return;
    }

    try {
      // Check if the user exists in Firestore
      final QuerySnapshot result = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .get();
      final List<DocumentSnapshot> documents = result.docs;
      if (documents.isEmpty) {
        // Email not found in Firestore
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              backgroundColor: Colors.white,
              title: Text("Login Error"),
              content: Text(
                'The email entered is not registered. Please check your email address or sign up.',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              actions: <Widget>[
                TextButton(
                  child: Text("OK"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
        return;
      }

      // Email found in Firestore, now check password
      final UserCredential userCredential =
          await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // After successful login, navigate to the home page
      Navigator.pushReplacementNamed(context, '/chatList');
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'wrong-password':
          errorMessage =
              'The password you entered is incorrect. Please check your password and try again.';
          break;
        default:
          errorMessage =
              'An error occurred during sign in. Please check your password.';
          break;
      }

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Colors.white,
            title: Text("Login Error"),
            content: Text(
              errorMessage,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            actions: <Widget>[
              TextButton(
                child: Text("OK"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }

  Future<void> resetPassword(String email) async {
    if (email.isEmpty) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Colors.white,
            title: Text("Reset Password Error"),
            content: Text(
              'Please enter your email address to reset your password.',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            actions: <Widget>[
              TextButton(
                child: Text("OK"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
      return;
    }

    try {
      await _auth.sendPasswordResetEmail(email: email);
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Colors.white,
            title: Text("Password Reset"),
            content: Text(
              'A password reset email has been sent to $email. Please check your inbox.',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            actions: <Widget>[
              TextButton(
                child: Text("OK"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    } catch (e) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Colors.white,
            title: Text("Reset Password Error"),
            content: Text(
              'An error occurred while trying to reset your password. Please try again later.',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            actions: <Widget>[
              TextButton(
                child: Text("OK"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title: Text('Log in'),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Log in',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 50.0,
                      fontFamily: "LilitaOne"),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 50), // add spacing between fields
                TextField(
                  textInputAction: TextInputAction.next,
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                            48)), // to make the text field box-shaped
                  ),
                ),
                SizedBox(height: 25),
                TextField(
                  textInputAction: TextInputAction.done,
                  controller: passwordController,
                  obscureText: _obscureText,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    suffixIcon: IconButton(
                      icon: Icon(_obscureText
                          ? Icons.visibility
                          : Icons.visibility_off),
                      onPressed: () {
                        setState(() {
                          _obscureText = !_obscureText;
                        });
                      },
                    ),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                            48)), // to make the text field box-shaped
                  ),
                ),
                SizedBox(height: 10),
                Align(
                  alignment: Alignment.center,
                  child: TextButton(
                    onPressed: () async {
                      try {
                        await resetPassword(emailController.text);
                      } catch (e) {
                        print('Error during password reset: $e');
                      }
                    },
                    child: Text('Forget Password?', style: TextStyle(color: Colors.blue[800])),
                  ),
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () async {
                    try {
                      await signInWithEmailAndPassword(
                        emailController.text,
                        passwordController.text,
                      );
                    } catch (e) {
                      // An error occurred
                      print('Error during login: $e');
                    }
                  },
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all(Colors.blue),
                  ),
                  child: SizedBox(
                    child: Text(
                      'Login',
                      style: TextStyle(color: Colors.white, fontSize: 30),
                      textAlign: TextAlign.center,
                    ),
                    width: 250,
                    height: 45,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}