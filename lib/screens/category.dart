import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:payment_tracker/function.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:payment_tracker/providers/provider.dart';

class CategoryScreen extends ConsumerStatefulWidget {
  const CategoryScreen({super.key});

  @override
  ConsumerState<CategoryScreen> createState() {
    return _CategoryScreenState();
  }
}

class _CategoryScreenState extends ConsumerState<CategoryScreen> {
  final _eventForm = GlobalKey<FormState>();
  var _eventName = '';
  var _address = '';
  var _mobile = '';
  final _eventDate = TextEditingController();
  DateTime? _edate;

  var _categoryId = '';
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

  void _saveEvent() async {
    final isValid = _eventForm.currentState!.validate();
    if (!isValid) {
      return;
    }
    _eventForm.currentState!.save();
    try {
      setState(() {
        _isSaving = true;
      });
      final user = FirebaseAuth.instance.currentUser!;
      FirebaseFirestore.instance.collection('events').add({
        'document_id': null,
        'name': _eventName,
        'category_id': _categoryId,
        'event_date': _edate,
        'address': _address,
        'mobile': _mobile,
        'user_id': user.uid,
        'created_at': Timestamp.now(),
      }).then((DocumentReference ref) {
        FirebaseFirestore.instance.collection('events').doc(ref.id).update({
          'document_id': ref.id,
        });
      });
      _message('success', 'Event Saved Successfully', Colors.green);
    } on FirebaseAuthException catch (err) {
      _message('error', err.message ?? 'Something Went Wrong', Colors.red);
    }
  }

  void _openCategoryForm(categoryId, categoryName) {
    _categoryId = categoryId;
    final catName = MyFunction.capitalize(categoryName);
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
                  'Add New Event for $catName',
                  style: TextStyle(
                    color: Colors.orange.shade800,
                    fontSize: 20,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(15),
                  child: Form(
                    key: _eventForm,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextFormField(
                          decoration: const InputDecoration(
                            labelText: 'Event Name',
                            labelStyle: TextStyle(
                              color: Colors.black,
                            ),
                          ),
                          keyboardType: TextInputType.text,
                          autocorrect: false,
                          textCapitalization: TextCapitalization.none,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Event Name should not be null.';
                            }
                            return null;
                          },
                          onSaved: (value) {
                            _eventName = value!;
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
                        const SizedBox(
                          height: 10,
                        ),
                        TextFormField(
                          controller: _eventDate,
                          decoration: const InputDecoration(
                            labelText: 'Event Date',
                            labelStyle: TextStyle(
                              color: Colors.black,
                            ),
                          ),
                          readOnly: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Event Date should not be null.';
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
                            onPressed: _saveEvent,
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

  void _removeCategory(docId) {
    try {
      FirebaseFirestore.instance.collection("categories").doc(docId).delete();
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.green,
          content: Text(
            'Category deleted successfully',
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
      stream: FirebaseFirestore.instance
          .collection('categories')
          .where('user_id', isEqualTo: authenticatedUser.uid)
          .orderBy(
            'created_at',
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
            child: Text('No categories found!'),
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
                    Icons.category,
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
                  trailing: IconButton(
                    onPressed: () {
                      _openCategoryForm(loadedData[index]['document_id'],
                          loadedData[index]['name']);
                    },
                    icon: const Icon(
                      Icons.add,
                      color: Colors.white,
                    ),
                  ),
                  onTap: () {
                    ref
                        .read(indexBottomNavbarProvider.notifier)
                        .update((state) => 2);
                    ref
                        .read(categoryIdProvider.notifier)
                        .update((state) => loadedData[index]['document_id']);
                  }),
            ),
            confirmDismiss: (direction) => showDialog(
              context: context,
              builder: ((context) => AlertDialog(
                    title: const Text('Are you sure?'),
                    content: const Text('Do you want to remove this category?'),
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
              _removeCategory(loadedData[index].data()['document_id']);
            },
          ),
        );
      },
    );
  }
}
