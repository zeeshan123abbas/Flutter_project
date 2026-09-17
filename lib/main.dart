import 'package:firebase_core/firebase_core.dart';
import 'package:firebse_auth/dashboard.dart';
import 'package:firebse_auth/firebase_options.dart';
import 'package:firebse_auth/home.dart';
import 'package:firebse_auth/mylogin.dart';
import 'package:firebse_auth/myregister.dart';
import 'package:firebse_auth/splash.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      // Splash sab se pehle open hoga
      initialRoute: '/splash',

      routes: {
        '/splash': (context) => const SplashScreen(),

        '/myregister': (context) => const Register(),

        '/mylogin': (context) => const MyLogin(),

        '/home': (context) => const Home(),

        '/dashboard': (context) => const Dashboard(),
      },
    );
  }
}







