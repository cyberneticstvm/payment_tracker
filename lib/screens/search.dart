// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:payment_tracker/function.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});
  @override
  State<StatefulWidget> createState() {
    return _SearchScreenState();
  }
}

class _SearchScreenState extends State<SearchScreen> {
  final authenticatedUser = FirebaseAuth.instance.currentUser!;
  final _searchForm = GlobalKey<FormState>();
  var _searchTerm = '';
  String selectedOption = 'name';
  bool _isFetching = false;
  Stream<QuerySnapshot>? _dataStream;
  double rtot = 0;
  double ptot = 0;

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
      _isFetching = false;
    });
  }

  void _fetch() {
    final isValid = _searchForm.currentState!.validate();
    if (!isValid) {
      return;
    }
    _searchForm.currentState!.save();
    try {
      setState(() {
        _isFetching = true;
      });
      var sby = (selectedOption == 'name') ? 'name' : 'mobile';
      _dataStream = FirebaseFirestore.instance
          .collection('contributors')
          .where(sby, isEqualTo: _searchTerm.toLowerCase())
          .where('user_id', isEqualTo: authenticatedUser.uid)
          .snapshots();
      setState(() {
        _isFetching = false;
      });
    } on FirebaseAuthException catch (err) {
      _message('error', err.message ?? 'Something went wrong', Colors.red);
    }
  }

  void _openContributorDetailSheet(docId) async {
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
                Text(
                  'Event Name: ${MyFunction.capitalize(data['event_name'] ?? 'NA')}',
                  style: const TextStyle(
                    color: Colors.black,
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(5.0),
              child: Row(
                children: [
                  Column(
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.50,
                        child: ListTile(
                          title: const Text('Search by Name'),
                          leading: Radio<String>(
                            activeColor: Colors.orange.shade800,
                            value: 'name',
                            groupValue: selectedOption,
                            onChanged: (value) {
                              setState(() {
                                selectedOption = value!;
                              });
                            },
                          ),
                        ),
                      )
                    ],
                  ),
                  Expanded(
                    child: ListTile(
                      title: const Text('Search by Mobile'),
                      leading: Radio<String>(
                        activeColor: Colors.orange.shade800,
                        value: 'mobile',
                        groupValue: selectedOption,
                        onChanged: (value) {
                          setState(() {
                            selectedOption = value!;
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Form(
                    key: _searchForm,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextFormField(
                          decoration: const InputDecoration(
                            labelText: 'Name / Mobile',
                            labelStyle: TextStyle(
                              color: Colors.black,
                            ),
                          ),
                          keyboardType: TextInputType.text,
                          autocorrect: false,
                          textCapitalization: TextCapitalization.none,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Search term should not be null.';
                            }
                            return null;
                          },
                          onSaved: (value) {
                            _searchTerm = value!;
                          },
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        if (_isFetching)
                          CircularProgressIndicator(
                            color: Colors.orange.shade800,
                          ),
                        if (!_isFetching)
                          ElevatedButton(
                            onPressed: _fetch,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange.shade800,
                            ),
                            child: const Text(
                              'Search',
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(5.0),
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
                            title: Text(
                              'Receipt: ${rtot.toString()}',
                              style: const TextStyle(
                                  color: Colors.green, fontSize: 20),
                            ),
                          ),
                        )
                      ],
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            'Payment: ${ptot.toString()}',
                            style: const TextStyle(
                                color: Colors.red, fontSize: 20),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Column(
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.30,
                ),
                Text(
                  'Balance: ${(rtot - ptot).abs().toString()}',
                  style: TextStyle(
                      color: (rtot - ptot >= 0) ? Colors.red : Colors.green,
                      fontSize: 20),
                ),
              ],
            ),
            StreamBuilder(
              stream: _dataStream,
              builder: (context, snapshot) {
                rtot = 0;
                ptot = 0;
                if (snapshot.hasError) {
                  return const Text('Something went wrong');
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator(
                    color: Colors.orange.shade800,
                  );
                }
                if (!snapshot.hasData) {
                  return const Text('No records found!');
                }
                final loadedData = snapshot.data!.docs;
                return ListView.builder(
                  padding: const EdgeInsets.only(
                    left: 15,
                    right: 15,
                  ),
                  shrinkWrap: true,
                  physics: const ClampingScrollPhysics(),
                  itemCount: loadedData.length,
                  itemBuilder: (ctx, index) {
                    if (loadedData[index]['type'] == 'receipt') {
                      rtot += double.parse(loadedData[index]['amount']);
                    }
                    if (loadedData[index]['type'] == 'payment') {
                      ptot += double.parse(loadedData[index]['amount']);
                    }
                    return Dismissible(
                      key: ValueKey(loadedData[index]),
                      direction: DismissDirection.none,
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
                                  width:
                                      MediaQuery.of(context).size.width * 0.50,
                                  child: ListTile(
                                    leading: Text('${index + 1}'.toString()),
                                    title: Text(loadedData[index]['name']),
                                    subtitle: Text(
                                      DateFormat.yMMMMd()
                                          .format(loadedData[index]
                                                  ['contributed_date']
                                              .toDate())
                                          .toString(),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    onTap: () {
                                      _openContributorDetailSheet(
                                          loadedData[index]['document_id']);
                                    },
                                  ),
                                )
                              ],
                            ),
                            Expanded(
                              child: Column(
                                children: [
                                  Text(
                                    loadedData[index]['type'],
                                    style: TextStyle(
                                        color: (loadedData[index]['type'] ==
                                                'payment')
                                            ? Colors.red
                                            : Colors.green),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Column(
                                children: [
                                  Text(
                                    loadedData[index]['amount'],
                                    style: TextStyle(
                                        color: (loadedData[index]['type'] ==
                                                'payment')
                                            ? Colors.red
                                            : Colors.green),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
