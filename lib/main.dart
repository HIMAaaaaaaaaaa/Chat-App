// ignore_for_file: unused_import

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'dart:ui';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photo_view/photo_view.dart'; 
import 'package:intl/intl.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_application_chat_app/Login.dart';
import 'package:flutter_application_chat_app/chat_list_page.dart'; // استيراد شاشة قائمة الدردشة
import 'package:flutter_application_chat_app/signup.dart'; // استيراد شاشة التسجيل
import 'package:flutter_application_chat_app/chat_screen.dart'; // استيراد شاشة الدردشة
import 'package:flutter_application_chat_app/HomePageSc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Intro(),
      routes: {
        '/Homepage': (context) => const Intro(),
        '/Login': (context) => LoginScreen(),
        '/Signup': (context) => SignupScreen(),
        '/chatList': (context) => ChatListPage(),
        '/chat': (context) => ChatScreen(
              receiverUserID: '',
              receiverUserEmail: '',
              receiverUserName: '',
              receiverUserphotoUrl: '',
            ),
        
      },
    );
  }
}





