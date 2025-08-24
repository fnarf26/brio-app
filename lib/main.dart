import 'package:brio/splash_screen.dart'; // <-- Ganti ini
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BRIO App',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        scaffoldBackgroundColor: const Color(0xFFF4F7FE),
      ),
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(), // <-- Ubah ini menjadi MainScreen()
    );
  }
}