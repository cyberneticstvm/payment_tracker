import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:payment_tracker/app_config.dart';

final _firebase = FirebaseAuth.instance;

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() {
    return _LoginScreenState();
  }
}

class _LoginScreenState extends State<LoginScreen> {
  final _loginForm = GlobalKey<FormState>();
  var _fullName = '';
  var _userName = '';
  var _password = '';
  bool _isAuthenticating = false;
  bool _isLogin = true;

  void _message(String status, String msg, Color color) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: color,
        content: Text(
          msg,
        ),
      ),
    );
    setState(() {
      _isAuthenticating = false;
    });
  }

  void _submit() async {
    final isValid = _loginForm.currentState!.validate();
    if (!isValid) {
      return;
    }
    _loginForm.currentState!.save();
    try {
      _userName = _userName + AppConfig.config['email']!['domain'].toString();
      setState(() {
        _isAuthenticating = true;
      });
      if (_isLogin) {
        await _firebase.signInWithEmailAndPassword(
          email: _userName,
          password: _password,
        );
      } else {
        //final users_count = FirebaseFirestore.instance.collection('users').count();
        final userCredentials = await _firebase.createUserWithEmailAndPassword(
          email: _userName,
          password: _password,
        );
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredentials.user!.uid)
            .set(
          {
            'user_id': userCredentials.user!.uid,
            'name': _fullName,
            'email': _userName,
            'password': _password,
            'created_at': Timestamp.now(),
          },
        );
      }
      _message('success', 'User Authenticated Successfully', Colors.green);
    } on FirebaseAuthException catch (err) {
      _message(
          'error',
          err.message.toString().contains('email')
              ? 'Username already exists'
              : err.message.toString(),
          Colors.red);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(
                height: 15,
              ),
              const Image(
                image: AssetImage('assets/images/logo-transparent.png'),
                height: 150,
                width: 150,
              ),
              const SizedBox(
                height: 15,
              ),
              Card(
                color: Colors.white,
                borderOnForeground: false,
                margin: const EdgeInsets.all(15),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(25),
                    child: Form(
                      key: _loginForm,
                      child: Column(
                        children: [
                          if (!_isLogin)
                            TextFormField(
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: 'Full Name',
                              ),
                              keyboardType: TextInputType.text,
                              enableSuggestions: false,
                              textCapitalization: TextCapitalization.none,
                              validator: (value) {
                                if (value == null || value.trim().length < 4) {
                                  return 'Name should be min 4 chars.';
                                }
                                return null;
                              },
                              onSaved: (value) {
                                _fullName = value!;
                              },
                            ),
                          const SizedBox(
                            height: 15,
                          ),
                          TextFormField(
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Username',
                              labelStyle: TextStyle(
                                color: Colors.black,
                              ),
                            ),
                            keyboardType: TextInputType.emailAddress,
                            autocorrect: false,
                            textCapitalization: TextCapitalization.none,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter a valid Username.';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              _userName = value!;
                            },
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          TextFormField(
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Password',
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
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          if (_isAuthenticating)
                            CircularProgressIndicator(
                              color: Colors.orange.shade800,
                            ),
                          if (!_isAuthenticating)
                            ElevatedButton(
                              onPressed: _submit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange.shade800,
                              ),
                              child: Text(
                                _isLogin ? 'Login' : 'Signup',
                                style: const TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          const SizedBox(
                            height: 10,
                          ),
                          if (!_isAuthenticating)
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  _isLogin = !_isLogin;
                                });
                              },
                              child: Text(_isLogin
                                  ? 'Create an account'
                                  : 'I already have an account'),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
