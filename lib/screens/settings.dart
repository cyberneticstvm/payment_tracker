import 'package:flutter/material.dart';
import 'package:payment_tracker/widgets/settings.dart';

class SettingScreen extends StatelessWidget {
  const SettingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Update Password'),
      ),
      body: const SettingsWidget(),
    );
  }
}
