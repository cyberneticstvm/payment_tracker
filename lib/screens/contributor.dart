// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:payment_tracker/function.dart';
import 'package:intl/intl.dart';

class ContributorScreen extends StatefulWidget {
  const ContributorScreen({super.key, required this.eventId});

  final String? eventId;

  @override
  State<ContributorScreen> createState() {
    return _ContributorScreenState();
  }
}

class _ContributorScreenState extends State<ContributorScreen> {
  void _removeContributor(docId) {
    try {
      FirebaseFirestore.instance.collection("contributors").doc(docId).delete();
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.green,
          content: Text(
            'Contributor deleted successfully',
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

  void _showContributorDetail(docId) async {
    final data = await FirebaseFirestore.instance
        .collection('contributors')
        .doc(docId)
        .get()
        .then((DocumentSnapshot doc) {
      return doc.data() as Map<String, dynamic>;
    });
    showModalBottomSheet(
      useSafeArea: true,
      isScrollControlled: true,
      context: context,
      builder: (BuildContext context) {
        return SizedBox(
          height: MediaQuery.of(context).size.height * 0.90,
          width: double.infinity,
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(
                  height: 50,
                ),
                const Text(
                  'Contributor Details',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 25,
                  ),
                ),
                const SizedBox(
                  height: 50,
                ),
                Text(
                  'Contributor Name: ${data['name']}',
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                  ),
                ),
                Text(
                  'Contributor Address: ${data['adress']}',
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                  ),
                ),
                Text(
                  'Contributor Mobile: ${data['mobile']}',
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                  ),
                ),
                Text(
                  'Contributed Date: ${DateFormat.yMMMMd().format(data['contributed_date'].toDate()).toString()}',
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                  ),
                ),
                Text(
                  'Amount: ${data['amount']}',
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                  ),
                ),
                Text(
                  'Type: ${MyFunction.capitalize(data['type'])}',
                  style: TextStyle(
                    color:
                        (data['type'] == 'receipt') ? Colors.green : Colors.red,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(
                  height: 15,
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
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authenticatedUser = FirebaseAuth.instance.currentUser!;
    return StreamBuilder(
      stream: (widget.eventId.toString().trim().isNotEmpty)
          ? FirebaseFirestore.instance
              .collection('contributors')
              .where('user_id', isEqualTo: authenticatedUser.uid)
              .where('event_id', isEqualTo: widget.eventId)
              .orderBy(
                'contributed_date',
                descending: true,
              )
              .snapshots()
          : FirebaseFirestore.instance
              .collection('contributors')
              .where('user_id', isEqualTo: authenticatedUser.uid)
              .orderBy(
                'contributed_date',
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
            child: Text('No contributors found!'),
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
              child: Row(
                children: [
                  Column(
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.50,
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
                            MyFunction.capitalize(loadedData[index]['name']),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                            ),
                          ),
                          tileColor: Colors.orange.shade800,
                          onTap: () {
                            _showContributorDetail(
                                loadedData[index]['document_id']);
                          },
                        ),
                      ),
                    ],
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          'Amount: ${loadedData[index]['amount']}',
                          style: TextStyle(
                              color: (loadedData[index]['type'] == 'receipt')
                                  ? Colors.green
                                  : Colors.red),
                        ),
                        Text(
                          DateFormat.yMMMMd()
                              .format(loadedData[index]['contributed_date']
                                  .toDate())
                              .toString(),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            confirmDismiss: (direction) => showDialog(
              context: context,
              builder: ((context) => AlertDialog(
                    title: const Text('Are you sure?'),
                    content:
                        const Text('Do you want to remove this contributor?'),
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
              _removeContributor(loadedData[index].data()['document_id']);
            },
          ),
        );
      },
    );
  }
}
