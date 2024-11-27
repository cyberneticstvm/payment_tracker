import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:page_transition/page_transition.dart';
import 'package:payment_tracker/screens/search.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final _categoryForm = GlobalKey<FormState>();
  var _categoryName = '';
  bool _isSaving = false;

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

  void _saveCategory() async {
    final isValid = _categoryForm.currentState!.validate();
    if (!isValid) {
      return;
    }
    _categoryForm.currentState!.save();
    try {
      setState(() {
        _isSaving = true;
      });
      final user = FirebaseAuth.instance.currentUser!;
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
    } on FirebaseAuthException catch (err) {
      _message('error', err.message ?? 'Something Went Wrong', Colors.red);
    }
  }

  void _openCategoryForm() {
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
                  'Add New Category',
                  style: TextStyle(
                    color: Colors.orange.shade800,
                    fontSize: 20,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(15),
                  child: Form(
                      key: _categoryForm,
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
                              onPressed: _saveCategory,
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

  void _openReminderForm() {
    //
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
                        onPressed: _openCategoryForm,
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
                        onPressed: _openReminderForm,
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
            )
          ],
        ),
      ),
    );
  }
}
