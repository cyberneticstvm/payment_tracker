import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:payment_tracker/screens/home.dart';
import 'package:payment_tracker/screens/login.dart';
import 'package:payment_tracker/screens/splash.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:awesome_notifications/awesome_notifications.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  AwesomeNotifications().initialize(null, [
    NotificationChannel(
      channelKey: 'ptracker',
      channelName: 'ptracker-reminder',
      channelDescription: 'Payment Tracker Reminder',
      ledColor: Colors.orange.shade800,
      enableVibration: true,
    ),
  ]);
  runApp(
    const ProviderScope(
      child: App(),
    ),
  );
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Payment Tracker',
      home: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SplashSreen();
          }
          if (snapshot.hasData) {
            return const HomeScreen();
          }
          return const LoginScreen();
        },
      ),
    );
  }
}
