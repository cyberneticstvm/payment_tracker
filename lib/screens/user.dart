import 'package:flutter/material.dart';
import 'package:payment_tracker/widgets/user.dart';

class UserScreen extends StatelessWidget {
  const UserScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User List'),
      ),
      body: const User(),
    );
  }
}
