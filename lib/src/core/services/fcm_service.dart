import 'dart:developer';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FcmService {
  final SupabaseClient _supabase;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  FcmService(this._supabase);

  Future<void> initialize() async {
    // 1. Request Permission
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      log('User granted permission');
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      log('User granted provisional permission');
    } else {
      log('User declined or has not accepted permission');
      return;
    }

    // 2. Get Token
    final fcmToken = await _firebaseMessaging.getToken();
    log('FCM Token: $fcmToken');

    // 3. Save to Database
    if (fcmToken != null) {
      await _saveTokenToDatabase(fcmToken);
    }

    // 4. Listen for Token Refresh
    _firebaseMessaging.onTokenRefresh.listen(_saveTokenToDatabase);

    // 5. Foreground Messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      log('Got a message whilst in the foreground!');
      if (message.notification != null) {
        log('Message also contained a notification: ${message.notification}');
      }
    });

    // 6. Listen for Auth Changes (Sync token after login)
    _supabase.auth.onAuthStateChange.listen((data) async {
      if (data.event == AuthChangeEvent.signedIn) {
        log('User signed in, syncing FCM token...');
        final token = await _firebaseMessaging.getToken();
        if (token != null) {
          await _saveTokenToDatabase(token);
        }
      }
    });
  }

  Future<void> _saveTokenToDatabase(String token) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    try {
      await _supabase
          .from('profiles')
          .update({'fcm_token': token})
          .eq('id', userId);
      log('FCM Token saved to Supabase');
    } catch (e) {
      log('Error saving FCM Token: $e');
    }
  }
}
