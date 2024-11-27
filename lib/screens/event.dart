import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:payment_tracker/function.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:payment_tracker/providers/provider.dart';

class EventScreen extends ConsumerStatefulWidget {
  const EventScreen({super.key, required this.categoryId});

  final String? categoryId;

  @override
  ConsumerState<EventScreen> createState() {
    return _EventScreenState();
  }
}

class _EventScreenState extends ConsumerState<EventScreen> {
  final _contributeForm = GlobalKey<FormState>();
  var _contributorName = '';
  var _ename = '';
  var _address = '';
  var _mobile = '';
  var _amount = '0';
  final _eventDate = TextEditingController();
  DateTime? _edate;

  bool _isSaving = false;

  void _pickedDate() async {
    await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime(DateTime.now().year + 10),
    ).then((pickedDate) {
      if (pickedDate == null) {
        return;
      }
      setState(() {
        _eventDate.text = DateFormat.yMMMMd().format(pickedDate).toString();
        _edate = pickedDate;
      });
    });
  }

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
      _isSaving = false;
    });
    if (status == 'success') {
      Navigator.pop(context);
    }
  }

  void _saveContributor(eventId, type) async {
    final isValid = _contributeForm.currentState!.validate();
    if (!isValid) {
      return;
    }
    _contributeForm.currentState!.save();
    try {
      setState(() {
        _isSaving = true;
      });
      final user = FirebaseAuth.instance.currentUser!;
      await FirebaseFirestore.instance.collection('contributors').add({
        'document_id': null,
        'name': _contributorName.toLowerCase(),
        'event_id': eventId,
        'event_name': _ename.toLowerCase(),
        'contributed_date': _edate,
        'address': _address.toLowerCase(),
        'mobile': _mobile,
        'amount': _amount,
        'type': type,
        'user_id': user.uid,
        'created_at': Timestamp.now(),
      }).then((DocumentReference ref) {
        FirebaseFirestore.instance
            .collection('contributors')
            .doc(ref.id)
            .update({
          'document_id': ref.id,
        });
      });
      _message('success', 'Contributor Saved Successfully', Colors.green);
    } on FirebaseAuthException catch (err) {
      _message('error', err.message ?? 'Something Went Wrong', Colors.red);
    }
  }

  void _openContributeForm(type, name, id) {
    _ename = name;
    showModalBottomSheet(
      useSafeArea: true,
      isScrollControlled: true,
      context: context,
      builder: (BuildContext context) {
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
                  'Add $type for $name',
                  style: TextStyle(
                    color: Colors.orange.shade800,
                    fontSize: 20,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(15),
                  child: Form(
                      key: _contributeForm,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextFormField(
                            decoration: const InputDecoration(
                              labelText: 'Contributor Name',
                              labelStyle: TextStyle(
                                color: Colors.black,
                              ),
                            ),
                            keyboardType: TextInputType.text,
                            autocorrect: false,
                            textCapitalization: TextCapitalization.none,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Contributor Name should not be null.';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              _contributorName = value!;
                            },
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          TextFormField(
                            decoration: const InputDecoration(
                              labelText: 'Address',
                              labelStyle: TextStyle(
                                color: Colors.black,
                              ),
                            ),
                            keyboardType: TextInputType.text,
                            autocorrect: false,
                            textCapitalization: TextCapitalization.none,
                            onSaved: (value) {
                              _address = value!;
                            },
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          TextFormField(
                            decoration: const InputDecoration(
                              labelText: 'Mobile',
                              labelStyle: TextStyle(
                                color: Colors.black,
                              ),
                            ),
                            keyboardType: TextInputType.number,
                            maxLength: 10,
                            onSaved: (value) {
                              _mobile = value!;
                            },
                          ),
                          TextFormField(
                            decoration: const InputDecoration(
                              labelText: 'Amount',
                              labelStyle: TextStyle(
                                color: Colors.black,
                              ),
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null ||
                                  value.isEmpty ||
                                  value == '0') {
                                return 'Amount should not be null.';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              _amount = value!;
                            },
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          TextFormField(
                            controller: _eventDate,
                            decoration: const InputDecoration(
                              labelText: 'Date',
                              labelStyle: TextStyle(
                                color: Colors.black,
                              ),
                            ),
                            readOnly: true,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Date should not be null.';
                              }
                              return null;
                            },
                            onTap: _pickedDate,
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          if (_isSaving)
                            CircularProgressIndicator(
                              color: Colors.orange.shade800,
                            ),
                          if (!_isSaving)
                            ElevatedButton(
                              onPressed: () {
                                _saveContributor(id, type);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange.shade800,
                              ),
                              child: const Text(
                                'Save',
                                style: TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text(
                              'Cancel',
                              style: TextStyle(color: Colors.orange.shade800),
                            ),
                          ),
                        ],
                      )),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _removeEvent(docId) {
    try {
      FirebaseFirestore.instance.collection("events").doc(docId).delete();
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.green,
          content: Text(
            'Event deleted successfully',
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
  void dispose() {
    super.dispose();
    _eventDate.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authenticatedUser = FirebaseAuth.instance.currentUser!;
    return StreamBuilder(
      stream: (widget.categoryId.toString().trim().isNotEmpty)
          ? FirebaseFirestore.instance
              .collection('events')
              .where('user_id', isEqualTo: authenticatedUser.uid)
              .where('category_id', isEqualTo: widget.categoryId)
              .orderBy(
                'event_date',
                descending: true,
              )
              .snapshots()
          : FirebaseFirestore.instance
              .collection('events')
              .where('user_id', isEqualTo: authenticatedUser.uid)
              .orderBy(
                'event_date',
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
            child: Text('No events found!'),
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
                            Icons.event,
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
                            ref
                                .read(indexBottomNavbarProvider.notifier)
                                .update((val) => 3);
                            ref.read(eventIdProvider.notifier).update(
                                (state) => loadedData[index]['document_id']);
                          },
                        ),
                      ),
                    ],
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        TextButton(
                          onPressed: () {
                            _openContributeForm(
                                'payment',
                                loadedData[index]['name'],
                                loadedData[index]['document_id']);
                          },
                          child: const Text(
                            'Payment',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        TextButton(
                          onPressed: () {
                            _openContributeForm(
                                'receipt',
                                loadedData[index]['name'],
                                loadedData[index]['document_id']);
                          },
                          child: const Text(
                            'Receipt',
                            style: TextStyle(color: Colors.green),
                          ),
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
                    content: const Text('Do you want to remove this event?'),
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
              _removeEvent(loadedData[index].data()['document_id']);
            },
          ),
        );
      },
    );
  }
}
