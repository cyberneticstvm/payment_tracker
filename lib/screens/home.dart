import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:payment_tracker/providers/provider.dart';
import 'package:payment_tracker/screens/category.dart';
import 'package:payment_tracker/screens/contributor.dart';
import 'package:payment_tracker/screens/event.dart';
import 'package:payment_tracker/widgets/drawer.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:payment_tracker/widgets/home.dart';
import 'package:payment_tracker/widgets/reminder.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() {
    return _HomeScreenState();
  }
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
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
      const Reminder()
    ];

    final activePageTitle = [
      'Home',
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
            onPressed: () {
              FirebaseAuth.instance.signOut();
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
