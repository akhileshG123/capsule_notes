import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("Handling a background message: ${message.messageId}");
}

class NotificationService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    // Request permissions
    await _messaging.requestPermission();

    // Init local notifications for foreground
    const initializationSettingsAndroid = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: null,
      macOS: null,
    );
    // const initializationSettings = InitializationSettings(android: initializationSettingsAndroid);
    await _localNotifications.initialize(settings: initializationSettings);

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        _showLocalNotification(message.notification!);
      }
    });

    // Save token
    String? token = await _messaging.getToken();
    if (token != null) {
      await _saveToken(token);
    }

    _messaging.onTokenRefresh.listen(_saveToken);
  }

  Future<void> _saveToken(String token) async {
    final user = _auth.currentUser;
    if (user != null) {
      await _firestore.collection('users').doc(user.uid).update({
        'fcmToken': token,
      });
    }
  }

  Future<void> _showLocalNotification(RemoteNotification notification) async {
    const androidDetails = AndroidNotificationDetails(
      'capsule_channel',
      'Capsule Unlocks',
      importance: Importance.max,
      priority: Priority.high,
    );

    const details = NotificationDetails(android: androidDetails);

    await _localNotifications.show(
      id: 0,
      title: notification.title,
      body: notification.body,
      notificationDetails: details,
    );
  }

  // Future<void> _showLocalNotification(RemoteNotification notification) async {
  //   const androidDetails = AndroidNotificationDetails(
  //     'capsule_channel',
  //     'Capsule Unlocks',
  //     importance: Importance.max,
  //     priority: Priority.high,
  //   );
  //   const details = NotificationDetails(android: androidDetails);
  //   await _localNotifications.show(
  //     0,
  //     notification.title,
  //     notification.body,
  //     details,
  //   );
  // }
}
