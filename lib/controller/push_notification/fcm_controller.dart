import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';

import 'package:medicalchat/view/chat/chat_view.dart';

class FcmController extends GetxController {
  final FirebaseMessaging _messaging =
      FirebaseMessaging.instance;

  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  final FirebaseAuth _auth =
      FirebaseAuth.instance;

  // ============================================================
  // LOCAL NOTIFICATIONS
  // ============================================================

  final FlutterLocalNotificationsPlugin
      _localNotifications =
      FlutterLocalNotificationsPlugin();

  static const String _channelId =
      'chat_messages';

  static const String _channelName =
      'Chat Messages';

  static const String _channelDescription =
      'Notifications for new chat messages';

  StreamSubscription<String>? _tokenSubscription;

  StreamSubscription<User?>? _authSubscription;

  StreamSubscription<RemoteMessage>?
      _foregroundMessageSubscription;

  StreamSubscription<RemoteMessage>?
      _notificationOpenedSubscription;

  bool _fcmInitialized = false;

  String? _lastSavedToken;

  // ============================================================
  // INIT
  // ============================================================

  @override
  void onInit() {
    super.onInit();

    debugPrint(
      'FCM CONTROLLER => INITIALIZING',
    );

    // ----------------------------------------------------------
    // AUTH STATE LISTENER
    // ----------------------------------------------------------

    _authSubscription =
        _auth.authStateChanges().listen(
      (User? user) async {
        if (user == null) {
          debugPrint(
            'FCM AUTH USER => LOGGED OUT',
          );

          _lastSavedToken = null;
          return;
        }

        debugPrint(
          'FCM AUTH USER => ${user.uid}',
        );

        await Future.delayed(
          const Duration(
            milliseconds: 500,
          ),
        );

        await saveToken();
      },
    );

    // ----------------------------------------------------------
    // INITIALIZE FCM
    // ----------------------------------------------------------

    _initializeFCM();
  }

  // ============================================================
  // INITIALIZE FCM
  // ============================================================

  Future<void> _initializeFCM() async {
    try {
      debugPrint(
        'FCM INIT => START',
      );

      // --------------------------------------------------------
      // LOCAL NOTIFICATIONS
      // --------------------------------------------------------

      await _initializeLocalNotifications();

      // --------------------------------------------------------
      // FCM PERMISSION
      // --------------------------------------------------------

      final NotificationSettings settings =
          await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      debugPrint(
        'FCM AUTHORIZATION STATUS => '
        '${settings.authorizationStatus}',
      );

      // --------------------------------------------------------
      // CURRENT USER
      // --------------------------------------------------------

      final User? currentUser =
          _auth.currentUser;

      debugPrint(
        'FCM CURRENT USER => '
        '${currentUser?.uid ?? 'NULL'}',
      );

      // --------------------------------------------------------
      // SAVE TOKEN
      // --------------------------------------------------------

      if (currentUser != null) {
        await saveToken();
      } else {
        debugPrint(
          'FCM INIT => No user currently logged in',
        );
      }

      // --------------------------------------------------------
      // PREVENT DUPLICATE LISTENERS
      // --------------------------------------------------------

      if (_fcmInitialized) {
        debugPrint(
          'FCM INIT => Already initialized',
        );

        return;
      }

      _fcmInitialized = true;

      // ========================================================
      // TOKEN REFRESH
      // ========================================================

      _tokenSubscription =
          _messaging.onTokenRefresh.listen(
        (String newToken) async {
          debugPrint(
            'FCM TOKEN REFRESHED',
          );

          debugPrint(
            'FCM REFRESH TOKEN => $newToken',
          );

          await _saveTokenToFirestore(
            newToken,
          );
        },
      );

      // ========================================================
      // FOREGROUND MESSAGE
      // ========================================================

      _foregroundMessageSubscription =
          FirebaseMessaging.onMessage.listen(
        (RemoteMessage message) async {
          debugPrint(
            'FOREGROUND NOTIFICATION '
            '=> ${message.messageId}',
          );

          debugPrint(
            'TITLE => '
            '${message.notification?.title}',
          );

          debugPrint(
            'BODY => '
            '${message.notification?.body}',
          );

          debugPrint(
            'DATA => ${message.data}',
          );

          await _showLocalNotification(
            message,
          );
        },
      );

      // ========================================================
      // BACKGROUND NOTIFICATION OPENED
      // ========================================================

      _notificationOpenedSubscription =
          FirebaseMessaging.onMessageOpenedApp.listen(
        (RemoteMessage message) {
          debugPrint(
            'NOTIFICATION OPENED '
            '=> ${message.messageId}',
          );

          debugPrint(
            'DATA => ${message.data}',
          );

          _handleNotificationNavigation(
            message,
          );
        },
      );

      // ========================================================
      // TERMINATED STATE
      // ========================================================

      final RemoteMessage? initialMessage =
          await _messaging.getInitialMessage();

      if (initialMessage != null) {
        debugPrint(
          'APP OPENED FROM NOTIFICATION '
          '=> ${initialMessage.messageId}',
        );

        debugPrint(
          'DATA => ${initialMessage.data}',
        );

        _handleNotificationNavigation(
          initialMessage,
        );
      }

      debugPrint(
        'FCM INIT => COMPLETE',
      );
    } catch (e, stackTrace) {
      debugPrint(
        'FCM INITIALIZATION ERROR => $e',
      );

      debugPrint(
        'FCM STACK TRACE => $stackTrace',
      );
    }
  }

  // ============================================================
  // LOCAL NOTIFICATION INITIALIZATION
  // ============================================================

  Future<void> _initializeLocalNotifications() async {
    try {
      debugPrint(
        'LOCAL NOTIFICATION => INITIALIZING',
      );

      const AndroidInitializationSettings
          androidSettings =
          AndroidInitializationSettings(
        'ic_notification',
      );

      const DarwinInitializationSettings
          iosSettings =
          DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const InitializationSettings settings =
          InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await _localNotifications.initialize(
        settings,
        onDidReceiveNotificationResponse:
            (NotificationResponse response) {
          debugPrint(
            'LOCAL NOTIFICATION TAPPED',
          );

          debugPrint(
            'PAYLOAD => ${response.payload}',
          );

          _handleLocalNotificationTap(
            response.payload,
          );
        },
      );

      // --------------------------------------------------------
      // ANDROID CHANNEL
      // --------------------------------------------------------

      const AndroidNotificationChannel
          channel =
          AndroidNotificationChannel(
        _channelId,
        _channelName,
        description:
            _channelDescription,
        importance:
            Importance.high,
        playSound:
            true,
      );

      final AndroidFlutterLocalNotificationsPlugin?
          androidPlugin =
          _localNotifications
              .resolvePlatformSpecificImplementation<
                  AndroidFlutterLocalNotificationsPlugin>();

      await androidPlugin
          ?.createNotificationChannel(
        channel,
      );

      // --------------------------------------------------------
      // ANDROID 13+
      // --------------------------------------------------------

      await androidPlugin
          ?.requestNotificationsPermission();

      debugPrint(
        'LOCAL NOTIFICATION => INITIALIZED',
      );
    } catch (e, stackTrace) {
      debugPrint(
        'LOCAL NOTIFICATION INIT ERROR => $e',
      );

      debugPrint(
        'LOCAL NOTIFICATION STACK TRACE => '
        '$stackTrace',
      );
    }
  }

  // ============================================================
  // SHOW FOREGROUND NOTIFICATION
  // ============================================================

  Future<void> _showLocalNotification(
    RemoteMessage message,
  ) async {
    try {
      String title =
          message.notification?.title ??
          'New Message';

      String body =
          message.notification?.body ??
          'You received a new message';

      // --------------------------------------------------------
      // IMAGE MESSAGE
      // --------------------------------------------------------

      if (message.data['messageType'] ==
              'image' ||
          message.data['type'] ==
              'image') {
        body = '📷 Image';
      }

      // --------------------------------------------------------
      // ANDROID
      // --------------------------------------------------------

      const AndroidNotificationDetails
          androidDetails =
          AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription:
            _channelDescription,
        importance:
            Importance.high,
        priority:
            Priority.high,
        playSound:
            true,
        enableVibration:
            true,
        icon:
            'ic_notification',
      );

      // --------------------------------------------------------
      // IOS
      // --------------------------------------------------------

      const DarwinNotificationDetails
          iosDetails =
          DarwinNotificationDetails(
        presentAlert:
            true,
        presentBadge:
            true,
        presentSound:
            true,
      );

      const NotificationDetails
          notificationDetails =
          NotificationDetails(
        android:
            androidDetails,
        iOS:
            iosDetails,
      );

      // --------------------------------------------------------
      // JSON PAYLOAD
      // --------------------------------------------------------
      //
      // message.data.toString() ki jagah JSON use kar rahe hain
      // taa ke notification tap par safely decode ho sake.
      //

      final String payload =
          jsonEncode(
        message.data,
      );

      // --------------------------------------------------------
      // SHOW
      // --------------------------------------------------------

      await _localNotifications.show(
        DateTime.now()
            .millisecondsSinceEpoch
            .remainder(
              100000,
            ),
        title,
        body,
        notificationDetails,
        payload:
            payload,
      );

      debugPrint(
        'LOCAL NOTIFICATION => SHOWN',
      );
    } catch (e, stackTrace) {
      debugPrint(
        'LOCAL NOTIFICATION SHOW ERROR => $e',
      );

      debugPrint(
        'LOCAL NOTIFICATION STACK TRACE => '
        '$stackTrace',
      );
    }
  }

  // ============================================================
  // LOCAL NOTIFICATION TAP
  // ============================================================

  void _handleLocalNotificationTap(
    String? payload,
  ) {
    if (payload == null ||
        payload.trim().isEmpty) {
      debugPrint(
        'LOCAL NOTIFICATION => EMPTY PAYLOAD',
      );

      return;
    }

    try {
      final dynamic decoded =
          jsonDecode(payload);

      if (decoded is! Map) {
        debugPrint(
          'LOCAL NOTIFICATION => INVALID PAYLOAD',
        );

        return;
      }

      final Map<String, dynamic> data =
          Map<String, dynamic>.from(
        decoded,
      );

      debugPrint(
        'LOCAL NOTIFICATION DATA => $data',
      );

      _openChatFromNotification(
        data,
      );
    } catch (e) {
      debugPrint(
        'LOCAL NOTIFICATION PAYLOAD ERROR => $e',
      );
    }
  }

  // ============================================================
  // NOTIFICATION NAVIGATION
  // ============================================================

  void _handleNotificationNavigation(
    RemoteMessage message,
  ) {
    final Map<String, dynamic> data =
        Map<String, dynamic>.from(
      message.data,
    );

    debugPrint(
      'NOTIFICATION DATA => $data',
    );

    _openChatFromNotification(
      data,
    );
  }

  // ============================================================
  // OPEN CHAT FROM NOTIFICATION
  // ============================================================

  void _openChatFromNotification(
    Map<String, dynamic> data,
  ) {
    try {
      final String type =
          data['type']?.toString() ?? '';

      debugPrint(
        'NOTIFICATION TYPE => "$type"',
      );

      if (type != 'chat') {
        debugPrint(
          'NOTIFICATION => Not a chat notification',
        );

        return;
      }

      final String chatId =
          data['chatId']?.toString() ?? '';

      final String patientId =
          data['patientId']?.toString() ?? '';

      final String doctorId =
          data['doctorId']?.toString() ?? '';

      final String patientName =
          data['patientName']?.toString() ?? '';

      final String patientImage =
          data['patientImage']?.toString() ?? '';

      final String doctorName =
          data['doctorName']?.toString() ?? '';

      final String doctorImage =
          data['doctorImage']?.toString() ?? '';

      final String doctorSpecialist =
          data['doctorSpecialist']?.toString() ?? '';

      debugPrint(
        'NOTIFICATION CHAT ID => $chatId',
      );

      debugPrint(
        'NOTIFICATION PATIENT ID => $patientId',
      );

      debugPrint(
        'NOTIFICATION DOCTOR ID => $doctorId',
      );

      // --------------------------------------------------------
      // BASIC VALIDATION
      // --------------------------------------------------------

      if (patientId.isEmpty ||
          doctorId.isEmpty) {
        debugPrint(
          'NOTIFICATION => Patient/Doctor ID missing',
        );

        return;
      }

      // --------------------------------------------------------
      // CHECK CURRENT USER
      // --------------------------------------------------------

      final User? currentUser =
          _auth.currentUser;

      if (currentUser == null) {
        debugPrint(
          'NOTIFICATION => User not logged in',
        );

        return;
      }

      final String currentUid =
          currentUser.uid;

      // --------------------------------------------------------
      // DETERMINE CURRENT ROLE
      // --------------------------------------------------------

      _openChatAfterNavigationReady(
        currentUid: currentUid,
        patientId: patientId,
        doctorId: doctorId,
        patientName: patientName,
        patientImage: patientImage,
        doctorName: doctorName,
        doctorImage: doctorImage,
        doctorSpecialist:
            doctorSpecialist,
      );
    } catch (e, stackTrace) {
      debugPrint(
        'NOTIFICATION NAVIGATION ERROR => $e',
      );

      debugPrint(
        'NOTIFICATION NAVIGATION STACK => '
        '$stackTrace',
      );
    }
  }

  // ============================================================
  // OPEN CHAT AFTER NAVIGATOR IS READY
  // ============================================================

  Future<void> _openChatAfterNavigationReady({
    required String currentUid,
    required String patientId,
    required String doctorId,
    required String patientName,
    required String patientImage,
    required String doctorName,
    required String doctorImage,
    required String doctorSpecialist,
  }) async {
    // ----------------------------------------------------------
    // Wait for Flutter/GetX navigation to become ready.
    // This is especially important when app was terminated.
    // ----------------------------------------------------------

    await Future.delayed(
      const Duration(
        milliseconds: 700,
      ),
    );

    // ----------------------------------------------------------
    // VERIFY CURRENT USER
    // ----------------------------------------------------------

    final User? user =
        _auth.currentUser;

    if (user == null ||
        user.uid != currentUid) {
      debugPrint(
        'NOTIFICATION => Current user changed',
      );

      return;
    }

    // ----------------------------------------------------------
    // CHECK IF CHAT IS ALREADY OPEN
    // ----------------------------------------------------------

    final String expectedChatId =
        '${patientId}_$doctorId';

    if (Get.currentRoute
        .contains('ChatView')) {
      debugPrint(
        'NOTIFICATION => ChatView already open',
      );
    }

    // ----------------------------------------------------------
    // CREATE DATA FOR CHATVIEW
    // ----------------------------------------------------------
    //
    // Patient ke liye ChatController doctor data read karega.
    // Doctor ke liye ChatController patientId read karega.
    //
    // Is liye dono sides ka complete data pass kar rahe hain.
    //

    final Map<String, dynamic>
        chatData = {
      'id': doctorId,
      'uid': doctorId,
      'doctorId': doctorId,

      'doctorName':
          doctorName.isNotEmpty
              ? doctorName
              : 'Doctor',

      'doctorImage':
          doctorImage,

      'doctorSpecialist':
          doctorSpecialist,

      'patientId':
          patientId,

      'patientName':
          patientName.isNotEmpty
              ? patientName
              : 'Patient',

      'patientImage':
          patientImage,

      'chatId':
          expectedChatId,
    };

    debugPrint(
      '========================================',
    );

    debugPrint(
      'OPENING CHAT FROM NOTIFICATION',
    );

    debugPrint(
      'CURRENT UID => $currentUid',
    );

    debugPrint(
      'PATIENT ID => $patientId',
    );

    debugPrint(
      'DOCTOR ID => $doctorId',
    );

    debugPrint(
      'CHAT ID => $expectedChatId',
    );

    debugPrint(
      '========================================',
    );

    // ----------------------------------------------------------
    // OPEN CHAT
    // ----------------------------------------------------------

    try {
      Get.to(
        () => ChatView(
          doctor: chatData,
        ),
      );

      debugPrint(
        'NOTIFICATION => CHAT OPENED',
      );
    } catch (e, stackTrace) {
      debugPrint(
        'CHAT NAVIGATION ERROR => $e',
      );

      debugPrint(
        'CHAT NAVIGATION STACK => $stackTrace',
      );
    }
  }

  // ============================================================
  // SAVE FCM TOKEN
  // ============================================================

  Future<void> saveToken() async {
    try {
      final User? user =
          _auth.currentUser;

      if (user == null) {
        debugPrint(
          'FCM TOKEN => No logged-in user',
        );

        return;
      }

      debugPrint(
        'FCM TOKEN => Getting token for UID '
        '${user.uid}',
      );

      final String? token =
          await _messaging.getToken();

      if (token == null ||
          token.isEmpty) {
        debugPrint(
          'FCM TOKEN => NULL OR EMPTY',
        );

        return;
      }

      debugPrint(
        'FCM TOKEN => RECEIVED',
      );

      if (_lastSavedToken == token) {
        debugPrint(
          'FCM TOKEN => Already saved for this session',
        );

        return;
      }

      await _saveTokenToFirestore(
        token,
      );
    } catch (e, stackTrace) {
      debugPrint(
        'FCM TOKEN ERROR => $e',
      );

      debugPrint(
        'FCM TOKEN STACK TRACE => $stackTrace',
      );
    }
  }

  // ============================================================
  // SAVE TOKEN TO FIRESTORE
  // ============================================================

  Future<void> _saveTokenToFirestore(
    String token,
  ) async {
    try {
      final User? user =
          _auth.currentUser;

      if (user == null) {
        debugPrint(
          'FCM FIRESTORE => No logged-in user',
        );

        return;
      }

      final String uid =
          user.uid;

      debugPrint(
        'FCM FIRESTORE => Saving token for $uid',
      );

      final DocumentReference<
              Map<String, dynamic>>
          patientRef =
          _firestore
              .collection('paitent')
              .doc(uid);

      await patientRef.set(
        {
          'fcmToken':
              token,
          'fcmTokenUpdatedAt':
              FieldValue.serverTimestamp(),
        },
        SetOptions(
          merge: true,
        ),
      );

      _lastSavedToken =
          token;

      debugPrint(
        'FCM TOKEN SAVED => $uid',
      );
    } catch (e, stackTrace) {
      debugPrint(
        'FCM TOKEN FIRESTORE ERROR => $e',
      );

      debugPrint(
        'FCM FIRESTORE STACK TRACE => $stackTrace',
      );
    }
  }

  // ============================================================
  // FORCE SAVE TOKEN
  // ============================================================

  Future<void> refreshAndSaveToken() async {
    debugPrint(
      'FCM FORCE SAVE => START',
    );

    _lastSavedToken =
        null;

    await saveToken();

    debugPrint(
      'FCM FORCE SAVE => COMPLETE',
    );
  }

  // ============================================================
  // REMOVE TOKEN
  // ============================================================

  Future<void> removeToken() async {
    try {
      final User? user =
          _auth.currentUser;

      if (user == null) {
        debugPrint(
          'FCM REMOVE => No logged-in user',
        );

        return;
      }

      await _firestore
          .collection('paitent')
          .doc(user.uid)
          .set(
        {
          'fcmToken':
              FieldValue.delete(),
          'fcmTokenUpdatedAt':
              FieldValue.delete(),
        },
        SetOptions(
          merge: true,
        ),
      );

      await _messaging.deleteToken();

      _lastSavedToken =
          null;

      debugPrint(
        'FCM TOKEN REMOVED => ${user.uid}',
      );
    } catch (e, stackTrace) {
      debugPrint(
        'FCM TOKEN REMOVE ERROR => $e',
      );

      debugPrint(
        'FCM REMOVE STACK TRACE => $stackTrace',
      );
    }
  }

  // ============================================================
  // CLEANUP
  // ============================================================

  @override
  void onClose() {
    _tokenSubscription?.cancel();

    _authSubscription?.cancel();

    _foregroundMessageSubscription
        ?.cancel();

    _notificationOpenedSubscription
        ?.cancel();

    debugPrint(
      'FCM CONTROLLER => CLOSED',
    );

    super.onClose();
  }
}