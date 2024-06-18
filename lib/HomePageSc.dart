import 'package:flutter/material.dart';
import 'Login.dart';
import 'SignUp.dart';

class Intro extends StatelessWidget {
  const Intro({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              color: Colors.white, // Background color for the top section
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Column(
                children: [
                  Text(
                    'Your Chat app',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.blue,
                      fontSize: 35,
                      fontFamily: "LilitaOne",
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              color: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MaterialButton(
                    minWidth: double.infinity,
                    height: 60,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => LoginScreen()),
                      );
                    },
                    child: Text(
                      'Log in',
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                        fontFamily: "LilitaOne",
                      ),
                    ),
                    color: Colors.blue, // Change to your desired color
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                      side: BorderSide(color: Colors.blue), // Change to your desired color
                    ),
                  ),
                  SizedBox(height: 20),
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'New to the app? ',
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.blue, // Change to your desired color
                            fontFamily: "LilitaOne",
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => SignupScreen()),
                            );
                          },
                          child: Text(
                            'Sign Up',
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.blue, // Change to your desired color
                              decoration: TextDecoration.underline,
                              fontFamily: "LilitaOne",
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
        ],
      ),
    );
  }
}