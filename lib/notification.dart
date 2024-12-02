/*import 'package:firebase_messaging/firebase_messaging.dart';

class PushNotificationService {
  void setupPushNotification() async {
    final fcm = FirebaseMessaging.instance;
    await fcm.requestPermission();
    fcm.subscribeToTopic('ptracker');
  }
}*/

import 'package:flutter/material.dart';
import 'package:awesome_notifications/awesome_notifications.dart';

class PushNotificationService {
  void initializeNotification(String body) {
    AwesomeNotifications().isNotificationAllowed().then(
      (isAllowed) {
        if (!isAllowed) {
          AwesomeNotifications().requestPermissionToSendNotifications();
        } else {
          AwesomeNotifications().createNotification(
            content: NotificationContent(
              id: 1,
              color: Colors.red,
              channelKey: 'ptracker',
              title: 'Payment Tracker Reminder',
              body: body,
              criticalAlert: true,
              wakeUpScreen: true,
            ),
          );
        }
      },
    );
  }
}
