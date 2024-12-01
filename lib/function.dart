import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

enum UserRoles {
  admin,
  user,
}

enum UserStatus {
  pending,
  blocked,
  approved,
}

final navigatorKey = GlobalKey<NavigatorState>();

class MyFunction {
  static String capitalize(String str) {
    return str[0].toUpperCase() + str.substring(1);
  }

  static currentUser(uid) async {
    final user = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get()
        .then((DocumentSnapshot doc) {
      if (doc.exists) return doc.data() as Map<String, dynamic>;
    });
    return user;
  }

  static checkUser(context) async {
    var msg = 'Approval Pending / Blocked User';
    final user = await currentUser(FirebaseAuth.instance.currentUser!.uid);
    if (user?['status'] == UserStatus.pending.name ||
        user?['status'] == UserStatus.blocked.name) {
      FirebaseAuth.instance.signOut();
      displayMessage(msg, context);
    }
  }

  static displayMessage(msg, context) {
    //BuildContext context = navigatorKey.currentContext!;
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.red,
        content: Text(
          msg,
        ),
      ),
    );
  }
}
