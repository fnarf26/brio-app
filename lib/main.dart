import 'package:brio/splash_screen.dart'; // <-- Ganti ini
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
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
      home: const SplashScreen(),
    );
  }
}

class FirebaseTestScreen extends StatefulWidget {
  const FirebaseTestScreen({super.key});

  @override
  State<FirebaseTestScreen> createState() => _FirebaseTestScreenState();
}

class _FirebaseTestScreenState extends State<FirebaseTestScreen> {
  String status = "⏳ Mengecek koneksi Firebase...";

  @override
  void initState() {
    super.initState();
    _checkRealtimeDB();
  }

  Future<void> _checkRealtimeDB() async {
    try {
      // Tampilkan URL dari firebase_options.dart
      final dbUrl = DefaultFirebaseOptions.currentPlatform.databaseURL;
      print("📡 Database URL: $dbUrl");

      // Referensi ke Realtime Database
      final dbRef = FirebaseDatabase.instance.ref("test/ping");

      // Tulis data
      await dbRef.set({
        "status": "ok",
        "timestamp": DateTime.now().toIso8601String(),
      });

      // Baca data
      final snapshot = await dbRef.get();

      if (snapshot.exists) {
        setState(() {
          status =
              "✅ Firebase Connected ke Realtime DB\nURL: $dbUrl\n\nData: ${snapshot.value}";
        });
      } else {
        setState(() {
          status = "⚠️ Firebase terhubung tapi data tidak ditemukan";
        });
      }
    } catch (e) {
      setState(() {
        status = "❌ Error: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Realtime Database Test")),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            status,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 18),
          ),
        ),
      ),
    );
  }
}
