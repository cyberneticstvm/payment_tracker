import 'package:flutter/material.dart';

class MainDrawer extends StatelessWidget {
  const MainDrawer({super.key});

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
          const Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 50,
              ),
              Center(
                child: Image(
                  image: AssetImage('assets/images/bmc_qr.png'),
                  height: 150,
                  width: 150,
                ),
              ),
              SizedBox(
                height: 15,
              ),
              Center(
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
