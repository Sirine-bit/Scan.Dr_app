import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:scan_dr1/screens/MainScreen.dart';
import 'package:scan_dr1/screens/home_screen.dart';
import 'package:scan_dr1/screens/login_screen.dart';
import 'package:scan_dr1/screens/health_profile_screen.dart';
import 'package:scan_dr1/screens/chronic_illness_screen.dart';
import 'package:scan_dr1/screens/age_selection_screen.dart';
import 'package:scan_dr1/firebase_options.dart';
import 'package:scan_dr1/screens/signup_screen.dart';
import 'package:scan_dr1/screens/chat_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Scan.Dr',
      theme: ThemeData(
        primarySwatch: Colors.lightBlue,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => HomePage(),
        '/login': (context) => LoginScreen(),
        '/age_selection': (context) => AgeSelectionScreen(),
        '/chronic_illness': (context) => ChronicIllnessScreen(),
        '/health_profile': (context) => HealthProfileScreen(),
        '/signup': (context) => SignUpScreen(),
        '/main_screen': (context) => MainScreen(),
        '/chat': (context) => ChatScreen(),
      },
    );
  }
}
