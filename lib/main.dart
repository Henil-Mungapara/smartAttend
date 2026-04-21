import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:smartattend/Admin_Dashboard/Admin_Main_Navigation_Screen.dart';
import 'package:smartattend/Admin_Dashboard/Admin_SetUp_Screen.dart';
import 'package:smartattend/Admin_Dashboard/SetUp_SmartAttend_Details/View_Collage_Screen.dart';
import 'package:smartattend/Auth/LogIn_Screen.dart';
import 'package:smartattend/Splash_Screen.dart';
import 'package:smartattend/Student_Dashboard/student_main_navigation.dart';
import 'package:smartattend/firebase_option_file/firebase_options.dart';

import 'Faculty_Dashboard/faculty_main_navigation.dart';

void main()async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform
  );
  runApp(SmartAttend());
}

class SmartAttend extends StatelessWidget {
  const SmartAttend({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SmartAttend',
      theme: ThemeData(
        primaryColor: const Color(0xFF3C9FB9),
      ),
      home: SplashScreen(),

    );
  }
}

