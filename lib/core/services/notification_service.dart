import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:permission_handler/permission_handler.dart';

import '../models/reminder_model.dart';
import '../models/customer_model.dart';

class NotificationService {
  static final NotificationService instance = NotificationService._init();
  
  final FlutterLocalNotificationsPlugin _localNotifications = 
      FlutterLocalNotificationsPlugin();
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  NotificationService._init();

  Future<void> initialize() async {
    // Request permissions
    await _requestPermissions();
    
    // Initialize local notifications
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    
    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
    
    // Initialize Firebase Messaging
    await _initializeFirebaseMessaging();
  }

  Future<void> _requestPermissions() async {
    await Permission.notification.request();
    
    final settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
    }
  }

  Future<void> _initializeFirebaseMessaging() async {
    // Get FCM token
    final token = await _firebaseMessaging.getToken();
    print('FCM Token: $token');
    
    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _showLocalNotification(
        title: message.notification?.title ?? 'Notification',
        body: message.notification?.body ?? '',
      );
    });
    
    // Handle background messages
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  void _onNotificationTapped(NotificationResponse response) {
    // Handle notification tap
    print('Notification tapped: ${response.payload}');
  }

  Future<void> _showLocalNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'frincy_channel',
      'Frincy Notifications',
      channelDescription: 'Notifications for payment reminders and updates',
      importance: Importance.high,
      priority: Priority.high,
    );
    
    const iosDetails = DarwinNotificationDetails();
    
    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
    
    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      details,
      payload: payload,
    );
  }

  Future<void> scheduleReminder(ReminderModel reminder, CustomerModel customer) async {
    if (reminder.sendPushNotification) {
      await _scheduleLocalNotification(
        id: reminder.id.hashCode,
        title: 'Payment Reminder',
        body: '${customer.name}: ${reminder.message}',
        scheduledDate: reminder.scheduledDate,
      );
    }
  }

  Future<void> _scheduleLocalNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'frincy_reminders',
      'Payment Reminders',
      channelDescription: 'Scheduled payment reminders',
      importance: Importance.high,
      priority: Priority.high,
    );
    
    const iosDetails = DarwinNotificationDetails();
    
    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
    
    await _localNotifications.zonedSchedule(
      id,
      title,
      body,
      scheduledDate,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> cancelReminder(String reminderId) async {
    await _localNotifications.cancel(reminderId.hashCode);
  }

  // WhatsApp Integration
  Future<void> sendWhatsAppMessage(String phoneNumber, String message) async {
    final cleanNumber = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
    final encodedMessage = Uri.encodeComponent(message);
    final url = 'https://wa.me/$cleanNumber?text=$encodedMessage';
    
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch WhatsApp';
    }
  }

  // SMS Integration
  Future<void> sendSMS(String phoneNumber, String message) async {
    final uri = Uri.parse('sms:$phoneNumber?body=${Uri.encodeComponent(message)}');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw 'Could not send SMS';
    }
  }

  // Payment reminder message templates
  String generatePaymentReminderMessage(CustomerModel customer, double amount) {
    return '''
Hello ${customer.name},

This is a friendly reminder about your pending payment of ₹${amount.toStringAsFixed(2)}.

Please make the payment at your earliest convenience.

Thank you!
''';
  }

  Future<void> sendPaymentReminder(
    ReminderModel reminder,
    CustomerModel customer,
  ) async {
    final message = reminder.message;
    
    if (reminder.sendWhatsApp && customer.phoneNumber != null) {
      try {
        await sendWhatsAppMessage(customer.phoneNumber!, message);
      } catch (e) {
        print('Failed to send WhatsApp message: $e');
      }
    }
    
    if (reminder.sendSMS && customer.phoneNumber != null) {
      try {
        await sendSMS(customer.phoneNumber!, message);
      } catch (e) {
        print('Failed to send SMS: $e');
      }
    }
    
    if (reminder.sendPushNotification) {
      await _showLocalNotification(
        title: 'Payment Reminder',
        body: '${customer.name}: $message',
      );
    }
  }
}

// Top-level function for background message handling
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Handling background message: ${message.messageId}');
}
