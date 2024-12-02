import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SettingsWidget extends StatefulWidget {
  const SettingsWidget({super.key});

  @override
  State<SettingsWidget> createState() => _SettingsWidgetState();
}

class _SettingsWidgetState extends State<SettingsWidget> {
  final _formKey = GlobalKey<FormState>();
  var _password = '';
  bool _isUpdating = false;

  void _message(String status, String msg, Color color) {
    setState(() {
      _isUpdating = false;
    });
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: color,
        content: Text(
          msg,
        ),
      ),
    );
  }

  void _submit() async {
    final isValid = _formKey.currentState!.validate();
    if (!isValid) {
      return;
    }
    _formKey.currentState!.save();
    try {
      setState(() {
        _isUpdating = true;
      });
      final user = FirebaseAuth.instance.currentUser!;
      await user.updatePassword(_password).then((_) {
        _formKey.currentState!.reset();
        _message('success', 'Password Updated Successfully', Colors.green);
      });
    } on FirebaseAuthException catch (err) {
      _message('error', err.message.toString(), Colors.red);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'New Password',
                    labelStyle: TextStyle(
                      color: Colors.black,
                    ),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a valid Password.';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _password = value!;
                  },
                  onTap: _submit,
                ),
                const SizedBox(
                  height: 10,
                ),
                if (_isUpdating)
                  CircularProgressIndicator(
                    color: Colors.orange.shade800,
                  ),
                if (!_isUpdating)
                  ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange.shade800,
                    ),
                    child: const Text(
                      'Update',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
