import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class ReminderScreen extends StatefulWidget {
  const ReminderScreen({super.key});

  @override
  State<ReminderScreen> createState() {
    return _ReminderScreenState();
  }
}

class _ReminderScreenState extends State<ReminderScreen> {
  void _removeReminder(docId) {
    try {
      FirebaseFirestore.instance.collection("reminders").doc(docId).delete();
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.green,
          content: Text(
            'Reminder deleted successfully',
          ),
        ),
      );
    } on FirebaseAuthException catch (err) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text(
            err.message!,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authenticatedUser = FirebaseAuth.instance.currentUser!;
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('reminders')
          .where('user_id', isEqualTo: authenticatedUser.uid)
          .orderBy(
            'reminder_date',
            descending: true,
          )
          .snapshots(),
      builder: (ctx, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          Center(
            child: CircularProgressIndicator(
              color: Colors.orange.shade800,
            ),
          );
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text('No reminders found!'),
          );
        }
        if (snapshot.hasError) {
          return const Center(
            child: Text('Something went wrong!'),
          );
        }
        final loadedData = snapshot.data!.docs;
        return ListView.builder(
          padding: const EdgeInsets.only(
            left: 15,
            right: 15,
            top: 25,
          ),
          itemCount: loadedData.length,
          itemBuilder: (ctx, index) => Dismissible(
            direction: DismissDirection.endToStart,
            key: ValueKey(loadedData[index]),
            background: Container(
              padding: const EdgeInsets.all(20),
              color: Colors.red,
              child: const Text(
                'Deleting...',
                style: TextStyle(color: Colors.white),
              ),
            ),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
                //set border radius more than 50% of height and width to make circle
              ),
              child: ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                  //set border radius more than 50% of height and width to make circle
                ),
                leading: const Icon(
                  Icons.notification_important,
                  color: Colors.white,
                ),
                title: Text(
                  loadedData[index]['title'],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                  ),
                ),
                tileColor: Colors.orange.shade800,
                subtitle: Text(
                  '${DateFormat.yMMMMd().format(loadedData[index]['reminder_date'].toDate())}, ${loadedData[index].data()['reminder_time']}',
                  style: TextStyle(color: Colors.brown.shade800),
                ),
              ),
            ),
            confirmDismiss: (direction) => showDialog(
              context: context,
              builder: ((context) => AlertDialog(
                    title: const Text('Are you sure?'),
                    content: const Text('Do you want to remove this reminder?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text('No'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        child: const Text('Yes'),
                      )
                    ],
                  )),
            ),
            onDismissed: (direction) {
              _removeReminder(loadedData[index].data()['document_id']);
            },
          ),
        );
      },
    );
  }
}
