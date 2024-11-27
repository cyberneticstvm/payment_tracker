import 'package:flutter/material.dart';
import 'package:payment_tracker/screens/home.dart';
import 'package:payment_tracker/screens/login.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:page_transition/page_transition.dart';

class SplashSreen extends StatefulWidget {
  const SplashSreen({super.key});
  @override
  State<SplashSreen> createState() {
    return _SplashScreenState();
  }
}

class _SplashScreenState extends State<SplashSreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(_controller);
    _controller.forward();

    Future.delayed(const Duration(seconds: 2), () async {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      if (prefs.getInt('userId') != null) {
        if (!mounted) return;
        Navigator.push(
          context,
          PageTransition(
            type: PageTransitionType.bottomToTop,
            child: const HomeScreen(),
          ),
        );
      } else {
        if (!mounted) return;
        Navigator.push(
          context,
          PageTransition(
            type: PageTransitionType.bottomToTop,
            child: const LoginScreen(),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FadeTransition(
              opacity: _animation,
              child: const Image(
                image: AssetImage('assets/images/logo-transparent.png'),
                height: 350,
                width: 350,
              ),
            )
          ],
        ),
      ),
    );
  }
}
