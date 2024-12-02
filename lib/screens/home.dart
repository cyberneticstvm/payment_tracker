import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:payment_tracker/function.dart';
import 'package:payment_tracker/notification.dart';
import 'package:payment_tracker/providers/provider.dart';
import 'package:payment_tracker/screens/category.dart';
import 'package:payment_tracker/screens/contributor.dart';
import 'package:payment_tracker/screens/event.dart';
import 'package:payment_tracker/screens/reminder.dart';
import 'package:payment_tracker/widgets/drawer.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:payment_tracker/widgets/home.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cron/cron.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() {
    return _HomeScreenState();
  }
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  Map<String, dynamic>? _currentUser;
  final cron = Cron();

  void _scheduleTask() {
    cron.schedule(Schedule.parse('*/1 * * * *'), () async {
      await FirebaseFirestore.instance
          .collection('reminders')
          .where('user_id', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
          .where('reminder_date',
              isEqualTo: DateTime(DateTime.now().year, DateTime.now().month,
                  DateTime.now().day))
          .get()
          .then((QuerySnapshot snapshot) {
        snapshot.docs.forEach((doc) {
          if (doc['reminder_time'] == TimeOfDay.now().format(context)) {
            setState(() {
              PushNotificationService().initializeNotification(doc['title']);
            });
          }
        });
      });
    });
  }

  void _getCurrentUser() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final u =
        await MyFunction.currentUser(FirebaseAuth.instance.currentUser!.uid);
    setState(() {
      _currentUser = u;
      prefs.setString('currentUserName', _currentUser?['name']);
      prefs.setString('currentUserRole', _currentUser?['role']);
      prefs.setString('currentUserStatus', _currentUser?['status']);
    });
  }

  @override
  void initState() {
    _getCurrentUser();
    _scheduleTask();
    MyFunction.checkUser(context);
    super.initState();
  }

  void _message(String msg, Color color) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: color,
        content: Text(
          msg,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final indexBottomNavbar = ref.watch(indexBottomNavbarProvider);
    //final activePageTitle = ref.watch(activePageTitleProvider);
    final categoryId = ref.watch(categoryIdProvider);
    final eventId = ref.watch(eventIdProvider);

    final bodies = [
      const Home(),
      const CategoryScreen(),
      EventScreen(categoryId: categoryId),
      ContributorScreen(eventId: eventId),
      const ReminderScreen()
    ];

    final activePageTitle = [
      'Hello ${_currentUser?['name']}',
      'Categories',
      'Events',
      'Contributors',
      'Reminders',
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(activePageTitle[indexBottomNavbar]),
        actions: [
          IconButton(
            onPressed: () async {
              final SharedPreferences prefs =
                  await SharedPreferences.getInstance();
              await prefs.remove('currentUserName');
              await prefs.remove('currentUserRole');
              await prefs.remove('currentUserStatus');
              FirebaseAuth.instance.signOut();
              _message("User logged out successfully", Colors.green);
            },
            icon: Icon(
              Icons.logout,
              color: Colors.grey.shade800,
            ),
          )
        ],
      ),
      drawer: const MainDrawer(),
      body: bodies[indexBottomNavbar],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          ref.read(categoryIdProvider.notifier).update((state) => '');
          ref.read(eventIdProvider.notifier).update((state) => '');
          ref.read(indexBottomNavbarProvider.notifier).update((state) => index);
        },
        currentIndex: indexBottomNavbar,
        unselectedItemColor: Colors.black,
        selectedItemColor: Colors.orange.shade800,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(
              Icons.home,
            ),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.category,
            ),
            label: 'Category',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.event,
            ),
            label: 'Events',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.person,
            ),
            label: 'Contributors',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.notification_important,
            ),
            label: 'Reminder',
          ),
        ],
      ),
    );
  }
}
