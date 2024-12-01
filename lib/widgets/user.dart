// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:payment_tracker/function.dart';
import 'package:intl/intl.dart';

class User extends StatefulWidget {
  const User({super.key});
  @override
  State<User> createState() {
    return _UserState();
  }
}

class _UserState extends State<User> {
  final _userForm = GlobalKey<FormState>();
  String userStatus = 'pending';

  void _handleStatusChange(String value, uid) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .update({'status': value});
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: Colors.green,
        content: Text(
          'Status updated successfully.',
        ),
      ),
    );
  }

  void _openUserForm(uName, uId) async {
    final data = await FirebaseFirestore.instance
        .collection('users')
        .doc(uId)
        .get()
        .then((DocumentSnapshot doc) {
      return doc.data() as Map<String, dynamic>;
    });
    userStatus = data['status'];
    showModalBottomSheet(
      useSafeArea: true,
      isScrollControlled: true,
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter myState) {
            return SizedBox(
              height: MediaQuery.of(context).size.height * 0.90,
              width: double.infinity,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const SizedBox(
                      height: 50,
                    ),
                    Text(
                      'Update $uName status',
                      style: TextStyle(
                        color: Colors.orange.shade800,
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Form(
                        key: _userForm,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ListTile(
                              title: const Text('Pending'),
                              leading: Radio<String>(
                                value: 'pending',
                                groupValue: userStatus,
                                activeColor: Colors.orange.shade800,
                                onChanged: (value) {
                                  myState(() => userStatus = value!);
                                  setState(() {
                                    _handleStatusChange(value!, uId);
                                  });
                                },
                              ),
                            ),
                            const SizedBox(
                              height: 15,
                            ),
                            ListTile(
                              title: const Text('Blocked'),
                              leading: Radio<String>(
                                value: 'blocked',
                                groupValue: userStatus,
                                activeColor: Colors.orange.shade800,
                                onChanged: (value) {
                                  myState(() => userStatus = value!);
                                  setState(() {
                                    _handleStatusChange(value!, uId);
                                  });
                                },
                              ),
                            ),
                            const SizedBox(
                              height: 15,
                            ),
                            ListTile(
                              title: const Text('Approved'),
                              leading: Radio<String>(
                                value: 'approved',
                                groupValue: userStatus,
                                activeColor: Colors.orange.shade800,
                                onChanged: (value) {
                                  myState(() => userStatus = value!);
                                  setState(() {
                                    _handleStatusChange(value!, uId);
                                  });
                                },
                              ),
                            ),
                            const SizedBox(
                              height: 25,
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Text(
                                'Close',
                                style: TextStyle(
                                  color: Colors.orange.shade800,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('users')
            .where('role', isEqualTo: 'user')
            .orderBy('name')
            .snapshots(),
        builder: (
          context,
          snapshot,
        ) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            Center(
              child: CircularProgressIndicator(
                color: Colors.orange.shade800,
              ),
            );
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text('No users found!'),
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
            itemBuilder: (ctx, index) => Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
                //set border radius more than 50% of height and width to make circle
              ),
              child: Row(
                children: [
                  Column(
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.90,
                        child: ListTile(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                            //set border radius more than 50% of height and width to make circle
                          ),
                          leading: const Icon(
                            Icons.person,
                            color: Colors.white,
                          ),
                          title: Text(
                            '${MyFunction.capitalize(loadedData[index]['name'])} (${loadedData[index]['email'].substring(0, loadedData[index]['email'].indexOf('@'))})',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                            ),
                          ),
                          tileColor: Colors.orange.shade800,
                          subtitle: Text(
                            'Status: ${MyFunction.capitalize(
                              loadedData[index]['status'],
                            )} | Craeted On: ${DateFormat.yMMMMd().format(loadedData[index]['created_at'].toDate()).toString()}',
                            style: TextStyle(color: Colors.green.shade100),
                          ),
                          onTap: () {
                            _openUserForm(loadedData[index]['name'],
                                loadedData[index]['user_id']);
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        });
  }
}
