import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:page_transition/page_transition.dart';
import 'package:payment_tracker/screens/search.dart';
import 'package:intl/intl.dart';

class Home extends ConsumerStatefulWidget {
  const Home({super.key});

  @override
  ConsumerState<Home> createState() => _HomeState();
}

class _HomeState extends ConsumerState<Home> {
  final _globalForm = GlobalKey<FormState>();
  var _categoryName = '';
  bool _isSaving = false;
  final _reminderDateTimeText = TextEditingController();
  final _reminderTimeText = TextEditingController();
  var _reminderTitle = '';
  DateTime? _reminderDateTime;
  String? _reminderTime;
  final user = FirebaseAuth.instance.currentUser!;

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
        _reminderDateTimeText.text =
            DateFormat.yMMMMd().format(pickedDate).toString();
        _reminderDateTime = pickedDate;
      });
    });
  }

  void _pickedTime() async {
    await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    ).then((pickedtime) {
      if (pickedtime == null) {
        return;
      }
      setState(() {
        _reminderTime = pickedtime.format(context);
        _reminderTimeText.text = pickedtime.format(context);
      });
    });
  }

  void _saveData(type) {
    final isValid = _globalForm.currentState!.validate();
    if (!isValid) {
      return;
    }
    _globalForm.currentState!.save();
    try {
      setState(() {
        _isSaving = true;
      });
      if (type == 'category') {
        FirebaseFirestore.instance
            .collection('categories')
            .where('name', isEqualTo: _categoryName.toLowerCase())
            .get()
            .then((snapshot) {
          if (snapshot.docs.isEmpty) {
            FirebaseFirestore.instance.collection('categories').add({
              'document_id': null,
              'name': _categoryName.toLowerCase(),
              'user_id': user.uid,
              'created_at': Timestamp.now(),
            }).then((DocumentReference ref) {
              FirebaseFirestore.instance
                  .collection('categories')
                  .doc(ref.id)
                  .update({
                'document_id': ref.id,
              });
            });
          } else {
            _message('error', 'Event category already exists', Colors.red);
          }
        });
        _message('success', 'Category Saved Successfully', Colors.green);
      } else {
        FirebaseFirestore.instance.collection('reminders').add({
          'document_id': null,
          'title': _reminderTitle,
          'reminder_date': _reminderDateTime,
          'reminder_time': _reminderTime,
          'user_id': user.uid,
          'created_at': Timestamp.now(),
        }).then((DocumentReference ref) {
          FirebaseFirestore.instance
              .collection('reminders')
              .doc(ref.id)
              .update({
            'document_id': ref.id,
          });
        });
        _message('success', 'Reminder Saved Successfully', Colors.green);
      }
    } on FirebaseAuthException catch (err) {
      _message('error', err.message ?? 'Something Went Wrong', Colors.red);
    }
  }

  void _openBottomSheet(type) {
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
                  (type == 'category')
                      ? 'Add New Category'
                      : 'Add New Reminder',
                  style: TextStyle(
                    color: Colors.orange.shade800,
                    fontSize: 20,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(15),
                  child: (type == 'category')
                      ? Form(
                          key: _globalForm,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              TextFormField(
                                decoration: const InputDecoration(
                                  labelText: 'Category Name',
                                  labelStyle: TextStyle(
                                    color: Colors.black,
                                  ),
                                ),
                                keyboardType: TextInputType.text,
                                autocorrect: false,
                                textCapitalization: TextCapitalization.none,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Category Name should not be null.';
                                  }
                                  return null;
                                },
                                onSaved: (value) {
                                  _categoryName = value!;
                                },
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
                                    _saveData('category');
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
                                  style:
                                      TextStyle(color: Colors.orange.shade800),
                                ),
                              ),
                            ],
                          ),
                        )
                      : Form(
                          key: _globalForm,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              TextFormField(
                                decoration: const InputDecoration(
                                  labelText: 'Title',
                                  labelStyle: TextStyle(
                                    color: Colors.black,
                                  ),
                                ),
                                keyboardType: TextInputType.text,
                                autocorrect: false,
                                textCapitalization: TextCapitalization.none,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Title should not be null.';
                                  }
                                  return null;
                                },
                                onSaved: (value) {
                                  _reminderTitle = value!;
                                },
                              ),
                              TextFormField(
                                controller: _reminderDateTimeText,
                                decoration: const InputDecoration(
                                  labelText: 'Reminder Date',
                                  labelStyle: TextStyle(
                                    color: Colors.black,
                                  ),
                                ),
                                keyboardType: TextInputType.text,
                                autocorrect: false,
                                textCapitalization: TextCapitalization.none,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Date should not be null.';
                                  }
                                  return null;
                                },
                                onTap: _pickedDate,
                              ),
                              TextFormField(
                                controller: _reminderTimeText,
                                decoration: const InputDecoration(
                                  labelText: 'Reminder Time',
                                  labelStyle: TextStyle(
                                    color: Colors.black,
                                  ),
                                ),
                                keyboardType: TextInputType.text,
                                autocorrect: false,
                                textCapitalization: TextCapitalization.none,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Time should not be null.';
                                  }
                                  return null;
                                },
                                onTap: _pickedTime,
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
                                    _saveData('reminder');
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
                                  style:
                                      TextStyle(color: Colors.orange.shade800),
                                ),
                              ),
                            ],
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
  void dispose() {
    super.dispose();
    _reminderDateTimeText.dispose();
    _reminderTimeText.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(25),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              children: [
                Expanded(
                  child: Card(
                    color: Colors.orange.shade800,
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: TextButton(
                        onPressed: () {
                          _openBottomSheet('category');
                        },
                        child: const Text(
                          'Add Category',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Card(
                    color: Colors.orange.shade800,
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: TextButton(
                        onPressed: () {
                          _openBottomSheet('reminder');
                        },
                        child: const Text(
                          'Add Reminder',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: Card(
                    color: Colors.orange.shade800,
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            PageTransition(
                              type: PageTransitionType.rightToLeft,
                              child: const SearchScreen(),
                            ),
                          );
                        },
                        child: const Icon(
                          Icons.search,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 15,
            ),
          ],
        ),
      ),
    );
  }
}
