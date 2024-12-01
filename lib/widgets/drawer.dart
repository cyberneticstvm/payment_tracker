import 'package:flutter/material.dart';
import 'package:payment_tracker/function.dart';
import 'package:payment_tracker/screens/user.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:page_transition/page_transition.dart';

class MainDrawer extends StatefulWidget {
  const MainDrawer({super.key});

  @override
  State<MainDrawer> createState() => _MainDrawerState();
}

class _MainDrawerState extends State<MainDrawer> {
  String? _currentUserRole;
  String? _currentUserName;

  void _getSharedPreferences() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _currentUserRole = prefs.getString('currentUserRole');
      _currentUserName = prefs.getString('currentUserName');
    });
  }

  @override
  void initState() {
    super.initState();
    _getSharedPreferences();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        // Important: Remove any padding from the ListView.
        padding: EdgeInsets.zero,
        children: [
          Container(
            margin: const EdgeInsets.only(
              top: 20,
              right: 20,
              bottom: 20,
              left: 20,
            ),
            height: 150,
            child: Image.asset('assets/images/logo-transparent.png'),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /*Padding(
                padding: const EdgeInsets.all(15.0),
                child: Text(
                  'Hello ${_currentUserName ?? ''}',
                  style: const TextStyle(
                    fontSize: 20,
                  ),
                ),
              ),*/
              if (_currentUserRole == UserRoles.admin.name)
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      PageTransition(
                        type: PageTransitionType.bottomToTop,
                        child: const UserScreen(),
                      ),
                    );
                  },
                  child: Text(
                    'Manage User',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.orange.shade800,
                    ),
                  ),
                ),
              TextButton(
                onPressed: () {
                  //
                },
                child: Text(
                  'Settings',
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.orange.shade800,
                  ),
                ),
              ),
              const SizedBox(
                height: 25,
              ),
              const Center(
                child: Image(
                  image: AssetImage('assets/images/bmc_qr.png'),
                  height: 150,
                  width: 150,
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              const Center(
                child: Text(
                  'Buy me a coffee!',
                  style: TextStyle(
                    fontSize: 25,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
