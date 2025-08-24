import 'dart:async';
import 'package:brio/main_screen.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Timer untuk pindah halaman setelah 3 detik
    Timer(const Duration(seconds: 3), () {
      // Pindah ke MainScreen dan hapus SplashScreen dari tumpukan navigasi
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const MainScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // Dekorasi untuk background gradasi
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF5347AD), Color(0xFF7654B2)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Menampilkan logo
              Image.asset(
                'assets/images/brio_logo_white.png', // Pastikan path ini benar
                height: 300, // Memperbesar lagi ukuran logo
                color: Colors.white, // Membuat logo menjadi warna putih
              ),
              const SizedBox(height: 20),
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
