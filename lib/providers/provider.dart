import 'package:flutter_riverpod/flutter_riverpod.dart';

final indexBottomNavbarProvider = StateProvider<int>((ref) {
  return 0;
});

final activePageTitleProvider = StateProvider<String>((ref) {
  return 'Home';
});

final categoryIdProvider = StateProvider<String>((ref) {
  return '';
});

final eventIdProvider = StateProvider<String>((ref) {
  return '';
});
