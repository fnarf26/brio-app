import 'package:brio/splash_screen.dart'; // <-- Ganti ini
import 'package:firebase_core/firebase_core.dart'; 
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'firebase_options.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('[FCM][Background] Diterima: ${message.notification?.title} | ${message.notification?.body}');
  _showNotification(message);
}

void _showNotification(RemoteMessage message) async {
  const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
    'brio_channel', 'Brio Notifikasi',
    importance: Importance.max,
    priority: Priority.high,
    showWhen: true,
  );
  const NotificationDetails notificationDetails =
      NotificationDetails(android: androidDetails);

  await flutterLocalNotificationsPlugin.show(
    message.notification.hashCode,
    message.notification?.title ?? 'Notifikasi',
    message.notification?.body ?? '',
    notificationDetails,
  );
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Inisialisasi local notification
  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'brio_channel',
    'Brio Notifikasi',
    description: 'Channel untuk notifikasi FCM Brio',
    importance: Importance.max,
  );
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  const AndroidInitializationSettings androidInitSettings =
      AndroidInitializationSettings('@mipmap/launcher_icon');
  const InitializationSettings initSettings =
      InitializationSettings(android: androidInitSettings);
  await flutterLocalNotificationsPlugin.initialize(initSettings);

  // Minta izin notifikasi (Android/iOS)
  await FirebaseMessaging.instance.requestPermission();

  // Subscribe ke topic "brio"
  await FirebaseMessaging.instance.subscribeToTopic('brio');

  // Handler background
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  
  // TAMBAHKAN INI: Handler foreground di global scope
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print('[FCM][Foreground] Diterima: ${message.notification?.title} | ${message.notification?.body}');
    _showNotification(message);
  });

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

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('[FCM][Foreground] Diterima: ${message.notification?.title} | ${message.notification?.body}');
      _showNotification(message);
    });
  }

  Future<void> _checkRealtimeDB() async {
    try {
      // Tampilkan URL dari firebase_options.dart
      final dbUrl = DefaultFirebaseOptions.currentPlatform.databaseURL; 

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
